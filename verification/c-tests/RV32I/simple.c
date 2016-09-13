 int main(void) { 
  int a=6;
  int b=3; 
  int *c = (int*)0x00000000;

  *c = a+b;

  //check if memory is as expected
  if(*c == 9) {
    *c = 1; 
  }
  
  //loop until test finishes
  while(1) {
  }
}
