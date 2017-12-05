#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void write_character(int x, int y, char c);
void add_graph_point(int y);

void display_waveform(short soundvalue)
{
	short maxsoundvalue = 32767;
	
	int scale = 100;
	int scaledvalue = (soundvalue * scale) / maxsoundvalue;

	int cap = 50; /* cap value in + or - directions */
	if (scaledvalue > cap) scaledvalue = cap;
	if (scaledvalue < -cap) scaledvalue = -cap;
	
	int y = 120 - scaledvalue;
	add_graph_point(y);
}

void display_zero_time()
{
	write_character(21, 50, '0');
	write_character(20, 50, '0');
	write_character(19, 50, '0');
}

/* for display seconds (3 digits) left in playback 
   r4 for the current position, r5 for the end */
void display_time_left(int cur_position, int end)
{
	int sec = (end - cur_position) / (8 * 44000);
	char buffer[12];
	sprintf(buffer, "%d", sec);

	if (isdigit(buffer[2])) 
	{
		write_character(21, 50, buffer[2]);
		write_character(20, 50, buffer[1]);
		write_character(19, 50, buffer[0]);
	} else {
		if (isdigit(buffer[1])) 
		{
			write_character(21, 50, buffer[1]);
			write_character(20, 50, buffer[0]);
			write_character(19, 50, '0');
		} else {
			if (isdigit(buffer[0])) 
			{
			write_character(21, 50, buffer[1]);
			write_character(20, 50, '0');
			write_character(19, 50, '0');
			} else {
				display_zero_time();
			}
		} 
	}
}


void playback_stop_c()
{
	char str[14] = "Playback Stop";
	size_t len = strlen(str);
	int x = 50;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}
void playing_c()
{
	char str[8] = "Playing";
	size_t len = strlen(str);
	int x = 50;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}
void record_stop_c()
{
	char str[11] = "Record Stop";
	size_t len = strlen(str);
	int x = 50;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}
void recording_c()
{
	char str[10] = "Recording";
	size_t len = strlen(str);
	int x = 50;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}
void pause_c()
{
	char str[6] = "Pause";
	size_t len = strlen(str);
	int x = 50;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}