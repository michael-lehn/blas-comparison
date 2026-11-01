// Prints NSProcessInfo.thermalState.  After bench/thermal.m of the ulmBLAS benchmark campaigns.
#import <Foundation/Foundation.h>
#include <stdio.h>
int main(void) {
    static const char *name[] = {"nominal", "fair", "serious", "critical"};
    long s = [[NSProcessInfo processInfo] thermalState];
    printf("%s\n", (s >= 0 && s < 4) ? name[s] : "unknown");
    return 0;
}
