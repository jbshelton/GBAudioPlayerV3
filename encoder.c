/*
    GBAudioPlayer, GBAudioPlayerV2, GBAudioPlayerV3 Copyright (c) 2020, 2021 Jackson Shelton.
    This code cannot be distributed without the creator's explicit permission.
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <unistd.h>

struct hq_lut_t
{
    uint8_t pulse_lut[256];
    uint8_t mv_lut[256];
    int amp_lut[256];
};

struct shq_lut_t
{
    uint8_t pulse_lut[1024][9];
    uint8_t mv_lut[1024][9];
    uint8_t nw_lut[1024][9];
    int amp_lut[1024];
    int repeats[1024];
    int prev_index;
    int prev_amp;
    int max_repeats;
    int max_index;
};

void init_hq_lut(struct hq_lut_t *hq_lut)
{
    for(int i=0; i<256; i++)
    {
        hq_lut->pulse_lut[i] = 0;
        hq_lut->mv_lut[i] = 0;
        hq_lut->amp_lut[i] = -1;
    }
}

void init_shq_lut(struct shq_lut_t *shq_lut)
{
    for(int j=0; j<2; j++)
    {
    for(int i=0; i<1024; i++)
    {
        shq_lut->pulse_lut[i][j] = 0;
        shq_lut->mv_lut[i][j] = 0;
        shq_lut->nw_lut[i][j] = 0;
        shq_lut->amp_lut[i] = -1;
        shq_lut->repeats[i] = 0;
        shq_lut->prev_index = 0;
        shq_lut->prev_amp = 0;
    }
    }
}

void generate_hq_lut(struct hq_lut_t *hq_lut)
{
    init_hq_lut(hq_lut);
    
    int pulse = 0;
    int uniqueamps = 0;
    int outamp = 0;

    for(int m=0; m<8; m++)
    {
        for(int p=0; p<8; p++)
        {
            pulse = (p*-1)-1;
            pulse = (pulse*2)+1;
            outamp = (int)(128.0+((128.0/120.0)*((double)(pulse*(m+1)))));

            if(hq_lut->amp_lut[outamp]==-1)
            {   
                uniqueamps++;
                hq_lut->pulse_lut[outamp] = (uint8_t)(7-p);
                hq_lut->mv_lut[outamp] = (uint8_t)m;
                hq_lut->amp_lut[outamp] = outamp;
            }

            pulse = p+1;
            pulse = (pulse*2)-1;
            outamp = (int)(127.0+((128.0/120.0)*((double)(pulse*(m+1)))));

            if(hq_lut->amp_lut[outamp]==-1)
            {   
                uniqueamps++;
                hq_lut->pulse_lut[outamp] = (uint8_t)(p+8);
                hq_lut->mv_lut[outamp] = (uint8_t)m;
                hq_lut->amp_lut[outamp] = outamp;
            }
        }
    }
    uint8_t temp_mv, temp_pulse;
    temp_pulse = 0;
    temp_mv = 0;
    int temp_amp;
    temp_amp = 0;

    for(int i=0; i<128; i++)
    {
        if(hq_lut->amp_lut[i]==i)
        {
            temp_pulse = hq_lut->pulse_lut[i];
            temp_mv = hq_lut->mv_lut[i];
            temp_amp = hq_lut->amp_lut[i];
        }
        else
        {
            hq_lut->pulse_lut[i] = temp_pulse;
            hq_lut->mv_lut[i] = temp_mv;
            hq_lut->amp_lut[i] = temp_amp;
        }
    }

    for(int i=255; i>=128; i--)
    {
        if(hq_lut->amp_lut[i]==i)
        {
            temp_pulse = hq_lut->pulse_lut[i];
            temp_mv = hq_lut->mv_lut[i];
            temp_amp = hq_lut->amp_lut[i];
        }
        else
        {
            hq_lut->pulse_lut[i] = temp_pulse;
            hq_lut->mv_lut[i] = temp_mv;
            hq_lut->amp_lut[i] = temp_amp;
        }
    }
}

void generate_shq_lut(struct shq_lut_t *shq_lut)
{
    init_shq_lut(shq_lut);
    
    int pulse = 0;
    int noisewave = 0;
    int uniqueamps = 0;
    int outamp = 0;

    for(int m=0; m<8; m++)
    {
        for(int nw=0; nw<3; nw++)
        {
            for(int p=0; p<8; p++)
            {
                if(nw==0)
                {
                    noisewave = 0;
                }
                else if(nw==1)
                {
                    noisewave = 15;
                }
                else
                {
                    noisewave = -15;
                }

                pulse = (p*-2)-1;
                outamp = (int)(512.0+((512.0/240.0)*((double)((pulse+noisewave)*(m+1)))));

                if(shq_lut->amp_lut[outamp]==-1)
                {   
                    uniqueamps++;
                    shq_lut->pulse_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)p;
                    shq_lut->mv_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)m;
                    shq_lut->nw_lut[outamp][shq_lut->repeats[outamp]] = (((uint8_t)nw)<<2);
                    shq_lut->amp_lut[outamp] = outamp;
                }
                else
                {
                    shq_lut->repeats[outamp]++;
                    shq_lut->pulse_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)p;
                    shq_lut->mv_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)m;
                    shq_lut->nw_lut[outamp][shq_lut->repeats[outamp]] = (((uint8_t)nw)<<2);
                }

                pulse = (p*2)+1;
                outamp = (int)(511.0+((512.0/240.0)*((double)((pulse+noisewave)*(m+1)))));

                if(shq_lut->amp_lut[outamp]==-1)
                {   
                    uniqueamps++;
                    shq_lut->pulse_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)p;
                    shq_lut->mv_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)m;
                    shq_lut->nw_lut[outamp][shq_lut->repeats[outamp]] = (((uint8_t)nw)<<2);
                    shq_lut->amp_lut[outamp] = outamp;
                }
                else
                {
                    shq_lut->repeats[outamp]++;
                    shq_lut->pulse_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)p;
                    shq_lut->mv_lut[outamp][shq_lut->repeats[outamp]] = (uint8_t)m;
                    shq_lut->nw_lut[outamp][shq_lut->repeats[outamp]] = (((uint8_t)nw)<<2);
                }
            }
        }
    }
    int max_repeats = 0;
    for(int i=0; i<1024; i++)
    {
        if(shq_lut->repeats[i]>max_repeats)
        {
            max_repeats = shq_lut->repeats[i];
            shq_lut->max_index = i;
        }
    }
    shq_lut->max_repeats = max_repeats;

    uint8_t temp_mv, temp_pulse, temp_nw;
    temp_pulse = 0;
    temp_mv = 0;
    temp_nw = 0;
    int temp_amp = 0;

    for(int j=0; j<max_repeats; j++)
    {
    for(size_t i=0; i<512; i++)
    {
        if(shq_lut->amp_lut[i]!=-1)
        {
            temp_pulse = shq_lut->pulse_lut[i][j];
            temp_mv = shq_lut->mv_lut[i][j];
            temp_nw = shq_lut->nw_lut[i][j];
            temp_amp = shq_lut->amp_lut[i];
        }
        else
        {
            shq_lut->pulse_lut[i][j] = temp_pulse;
            shq_lut->mv_lut[i][j] = temp_mv;
            shq_lut->nw_lut[i][j] = temp_nw;
            shq_lut->amp_lut[i] = temp_amp;
        }
    }

    for(size_t i=511; i>0; i--)
    {
        if(shq_lut->amp_lut[i]!=-1)
        {
            temp_pulse = shq_lut->pulse_lut[i][j];
            temp_mv = shq_lut->mv_lut[i][j];
            temp_nw = shq_lut->nw_lut[i][j];
            temp_amp = shq_lut->amp_lut[i];
        }
        else
        {
            shq_lut->pulse_lut[i][j] = temp_pulse;
            shq_lut->mv_lut[i][j] = temp_mv;
            shq_lut->nw_lut[i][j] = temp_nw;
            shq_lut->amp_lut[i] = temp_amp;
        }
    }

    for(size_t i=1023; i>=512; i--)
    {
        if(shq_lut->amp_lut[i]!=-1)
        {
            temp_pulse = shq_lut->pulse_lut[i][j];
            temp_mv = shq_lut->mv_lut[i][j];
            temp_nw = shq_lut->nw_lut[i][j];
            temp_amp = shq_lut->amp_lut[i];
        }
        else
        {
            shq_lut->pulse_lut[i][j] = temp_pulse;
            shq_lut->mv_lut[i][j] = temp_mv;
            shq_lut->nw_lut[i][j] = temp_nw;
            shq_lut->amp_lut[i] = temp_amp;
        }
    }

    for(size_t i=512; i<1024; i++)
    {
        if(shq_lut->amp_lut[i]!=-1)
        {
            temp_pulse = shq_lut->pulse_lut[i][j];
            temp_mv = shq_lut->mv_lut[i][j];
            temp_nw = shq_lut->nw_lut[i][j];
            temp_amp = shq_lut->amp_lut[i];
        }
        else
        {
            shq_lut->pulse_lut[i][j] = temp_pulse;
            shq_lut->mv_lut[i][j] = temp_mv;
            shq_lut->nw_lut[i][j] = temp_nw;
            shq_lut->amp_lut[i] = temp_amp;
        }
    }
    }
}

int main(int argc, const char * argv[])
{
    if (argc != 5) {
        printf("Usage: %s output_dir encoding_type aud_channels timer_div\n", argv[0]);
        return -1;
    }

    char output_dir[128];
    printf("No. of channels: %d\n", atoi(argv[3]));
    strcat(output_dir, "output/build");

    printf("%s\n", output_dir);
    int is_ok = chdir(output_dir);
    printf("%d\n", is_ok);

    int timer_div = (256 - atoi(argv[4]));
    char tim_div[64];
    sprintf(tim_div, "%d", timer_div);
    strcat(tim_div, "\n");
    char div_line[64];
    strcpy(div_line, "\tld a, ");
    strcat(div_line, tim_div);

    FILE *div_val;
    if((div_val = fopen("div.asm", "w"))<0)
    {
         printf("Error: couldn't create div.asm\n");
         return 1;   
    }
    fputs(div_line, div_val);
    fclose(div_val);

    is_ok = chdir("..");
    is_ok = chdir(argv[1]);
    printf("%d\n", is_ok);

    FILE *audiof = fopen("audio.raw", "rb"); //binary read mode (bytes)
    if (!audiof) {
        perror("Failed to load audio source file");
        return 1;
    }

    fseek(audiof, 0, SEEK_END);
    size_t audio_size;
    int audio_mode = 0;
    uint8_t aud_channels = (uint8_t)atoi(argv[3]);

    char *en_mode;

    if((en_mode = strstr(argv[2], "leg"))!=NULL)
    {
        audio_size = ftell(audiof)/2;
        audio_mode = 0;
    }
    else if((en_mode = strstr(argv[2], "shq"))!=NULL)
    {
        if(aud_channels==2)
        {    
            audio_size = (size_t)((ftell(audiof)/4)*3);
            audio_size += (audio_size/16383)+1;
        }
        else
        {
            audio_size = ftell(audiof);
        }
        audio_mode = 2;
    }
    else //if((en_mode = strstr(argv[2], "hq"))!=NULL)
    {
        audio_size = ftell(audiof);
        audio_mode = 1;
    }
    

    struct hq_lut_t *hq_lut = (struct hq_lut_t *)(malloc(sizeof(struct hq_lut_t)));
    generate_hq_lut(hq_lut);

    struct shq_lut_t *shq_lut = (struct shq_lut_t *)(malloc(sizeof(struct shq_lut_t)));
    generate_shq_lut(shq_lut);

    fseek(audiof, 0 , SEEK_SET);

    size_t main_pos = 0;
    
    static uint8_t *output;
    output = (uint8_t *)malloc(audio_size);
    memset(output, 0, audio_size);

    bool done = false;

    if(audio_mode==0)
    {
        while(!done)
        {
            uint8_t left, right;
            if(fread(&left, 1, 1, audiof) != 1 || fread(&right, 1, 1, audiof) != 1) 
            {
                left = right = 0x80;
                done = true;
            }
            output[main_pos++] = ((left/17)<<4)|(right/17);
        }
    }
    if(audio_mode==1)
    {
        if(aud_channels==2)
        {   
            while(!done)
            {
                uint8_t left, right;
                if(fread(&left, 1, 1, audiof) != 1 || fread(&right, 1, 1, audiof) != 1) 
                {
                    left = right = 0x80;
                    done = true;
                }

                output[main_pos++] = (((hq_lut->pulse_lut[left]&0x0f)<<4)|(hq_lut->pulse_lut[right]&0x0f));
                output[main_pos++] = (((hq_lut->mv_lut[left]&0x07)<<4)|(hq_lut->mv_lut[right]&0x07));
            }
        }
        if(aud_channels==1)
        {
            while(!done)
            {   
                uint8_t samp;
                if(fread(&samp, 1, 1, audiof) != 1)
                {
                    samp = 0x80;
                    done = true;
                }
                output[main_pos++] = (((hq_lut->pulse_lut[samp]&0x0f)<<4)|(hq_lut->mv_lut[samp]&0x07));
            }
        }
    }
    if(audio_mode==2)
    {
        if(aud_channels==2)
        {   
            main_pos++;
            while(!done)
            {
                uint16_t left, right;
                uint8_t *left_read = (uint8_t *)&left;
                uint8_t *right_read = (uint8_t *)&right;

                if(fread(left_read, 2, 1, audiof)!=1 || fread(right_read, 2, 1, audiof)!=1)
                {   
                    left = right = 0;
                    done=true;
                }

                left = (left^0x8000)>>6;
                right = (right^0x8000)>>6;

                output[main_pos++] = (((shq_lut->pulse_lut[left][0]&0x0f)<<4)|(shq_lut->pulse_lut[right][0]&0x0f));
                output[main_pos++] = ((((shq_lut->mv_lut[left][0]&0x07))<<4)|(shq_lut->mv_lut[right][0]&0x07));
                output[main_pos++] = ((((shq_lut->nw_lut[left][0])<<4)|shq_lut->nw_lut[right][0])&0xcc)|0x12;

                if((main_pos&0x3fff)==0)
                {
                    main_pos++;
                }
            }
        }
        if(aud_channels==1)
        {
            while(!done)
            {   
                uint16_t samp;
                uint8_t *samp_read = (uint8_t *)&samp;
                if(fread(samp_read, 2, 1, audiof) != 1)
                {
                    samp = 0;
                    done = true;
                }

                samp = (samp^0x8000)>>6;

                output[main_pos++] = (((shq_lut->pulse_lut[samp][0]&0x0f)<<4)|(shq_lut->mv_lut[samp][0]&0x07));
                output[main_pos++] = ((shq_lut->nw_lut[samp][0]<<4)|shq_lut->nw_lut[samp][0])|0x11;
            }
        }
    }
    free(hq_lut);
    free(shq_lut);
    fclose(audiof);
    FILE *out_aud = fopen("audio_encoded.raw", "wb");
    if(!out_aud) 
    {
        perror("Error: cannot write to output audio file\n");
        return 1;
    }
    fwrite(output, 1, audio_size, out_aud);
    fclose(out_aud);
    free(output);
    printf("Audio has been encoded!\n");
}