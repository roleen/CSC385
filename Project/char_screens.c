#include <stdio.h>
#include <string.h>

void write_character(int x, int y, char c);

/*
void display_number(int num)
{
	char str[12];
	sprintf(str, "%d", num);
	size_t len = strlen(str);
	int x = 30;
	for (int i = 0; i < len; i++)
	{
		write_character(x, 50, str[i]);
		x++;
	}	
}*/

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