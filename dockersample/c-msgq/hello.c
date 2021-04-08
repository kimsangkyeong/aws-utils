#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main()
{
    time_t rawtime;
    struct tm *ptm = NULL;

    for(;;)
    {
        rawtime = time(NULL);
        ptm = localtime(&rawtime);
 
        printf("Hello World! - %d/%d %02d:%02d:%02d \n", 
                      ptm->tm_mon+1, ptm->tm_mday, ptm->tm_hour, ptm->tm_min, ptm->tm_sec);
        fflush(stdout);
        sleep(2); // 2 second delay
    }
    return 0;
}
