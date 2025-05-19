void setup(void);     void loop(void);
extern                             "C"  
{
  void init_ADC                (void);
  void read_ADC                (void);
};
#                         ifndef BRAIN
#                         define BRAIN
auto main(int argc, const char **argv) 
->                      decltype(0x00) 
{
    setup                           ();
    while  (true) {      loop();      }
    return (true) ?         0x00: 0x01;
};
#                                 endif
inline auto                 setup(void) 
-> void {         init_ADC();        };
inline auto                  loop(void) 
-> void {         read_ADC();        };