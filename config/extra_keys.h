// The default layout has 42 keys. Additional keys can be added by pre-setting any of
// the macros defined in this file to one or more keys before sourcing this file.

#if !defined DEF_X_TOP // top row for solfe / lily for the default layer - this includes 12 keys
    #define DEF_X_TOP
#endif

#if !defined NON_DEF_X_TOP // top row for solfe / lily for non default layers - this includes 12 keys
    #define NON_DEF_X_TOP
#endif

#if !defined X_RT // extra right thumb keys for solfe - this includes 2 keys
    #define X_RT
#endif

#if !defined X_LT // extra left thumb keys for solfe - this includes 2 keys
    #define X_LT
#endif

#if !defined X_ENC // extra encoder knobs - this includes left and right knobs
    #define X_ENC
#endif
