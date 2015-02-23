#include <stdio.h>
#include <string.h>
#include "includes.h"
#include "altera_up_avalon_character_lcd.h"
#define   TASK_STACKSIZE       2048
#define TASK1_PRIORITY      1
#define NUMBER_OF_LASER 8

/* Definition of Task Stacks */
OS_STK    task1_stk[TASK_STACKSIZE];


const char * getBinary(int x,int length){
    static char b[9];
    b[0] = '\0';
    int z;
    for (z = 128; z > 0; z >>= 1){
        strcat(b, ((x & z) == z) ? "1" : "0");
    }
    return b;
}

char * getMappedNote(int laserNumber){
	static char noteMap[8][10] = {"C","D","E","F","G","A","B","C"};
	return noteMap[laserNumber];
}

void handleLaserStatusChange(int previousStatus, int currentStatus){
	int i;
	int noteType; //0 = off 1 = on
	//Find bits that are different
	//XOR: 100 ^ 110 = 010
	int differentBits = previousStatus^currentStatus;
	for (i=0;i<NUMBER_OF_LASER;i++){
		/*
		printf("(1<<i): %i\n",(1 << i) );
		printf("differentBits: %i\n",differentBits );
		printf("(1 << i) & (differentBits): %i\n",(1 << i) & (differentBits) );
		printf("equal?: %i\n", ((1 << i) & (differentBits)) == (1 << i) );
		*/
		if( ((1 << i) & (differentBits)) == (1 << i) ){

			noteType = ((currentStatus &  (1 << i)) ==  (1 << i)) ?  1: 0;

			printf("Note %i\n",i);
			printf("NoteType %i\n",noteType);

		}
	}

}



/* Prints "Hello World" and sleeps for three seconds */
void task1(void* pdata)
{
	int previousLaserStatus;
	int laserStatus;
	alt_up_character_lcd_dev * char_lcd_dev;

	char_lcd_dev = alt_up_character_lcd_open_dev ("/dev/character_lcd_0");
	if ( char_lcd_dev == NULL)
		alt_printf ("Error: could not open character LCD device\n");
	else
		alt_printf ("Opened character LCD device\n");
	alt_up_character_lcd_init (char_lcd_dev);
	alt_up_character_lcd_set_cursor_pos(char_lcd_dev, 0, 0);
	alt_up_character_lcd_string(char_lcd_dev, "MIDIGeneratorPrototype");


	int* pointer =(int* )SWITCH_BASE;
	while (1){
		previousLaserStatus = laserStatus;
		laserStatus = *pointer;

		if (previousLaserStatus!=laserStatus){
			handleLaserStatusChange(previousLaserStatus,laserStatus);

			//Debug only======================================
			alt_up_character_lcd_init (char_lcd_dev);
			alt_up_character_lcd_set_cursor_pos(char_lcd_dev, 0, 0);
			alt_up_character_lcd_string(char_lcd_dev,"Laser Status:");
			alt_up_character_lcd_set_cursor_pos(char_lcd_dev, 0, 1);
			alt_up_character_lcd_string(char_lcd_dev, getBinary(laserStatus,NUMBER_OF_LASER));
			//end of debug======================================
		}
	}
}

/* The main function creates two task and starts multi-tasking */
int main(void)
{

	OSTaskCreateExt(task1,
			NULL,
			(void *)&task1_stk[TASK_STACKSIZE-1],
			TASK1_PRIORITY,
			TASK1_PRIORITY,
			task1_stk,
			TASK_STACKSIZE,
			NULL,
			0);


	OSStart();
	return 0;
}
