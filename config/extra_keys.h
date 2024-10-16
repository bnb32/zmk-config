// The default layout has 42 keys. Additional keys can be added by pre-setting any of
// the macros defined in this file to one or more keys before sourcing this file.

// top row for solfe / lily for the default layer - this includes 12 keys
#if !defined X_TOP_DEF
    #define X_TOP_DEF
#endif

// top row for solfe / lily for non default layers - this includes 12 keys
#if !defined X_TOP_NON_DEF
    #define X_TOP_NON_DEF
#endif

// extra right thumb keys for default layer - this includes 1 key for corne, 2 keys for lily, and 3 keys for sofle
#if !defined X_RT_DEF
    #define X_RT_DEF
#endif

// extra left thumb keys for default layer - this includes 1 key for corne, 2 keys for lily, and 3 keys for sofle
#if !defined X_LT_DEF
    #define X_LT_DEF
#endif

// extra right thumb keys for non default layers - this includes 1 key for corne, 2 keys for lily, and 3 keys for sofle
#if !defined X_RT_NON_DEF
    #define X_RT_NON_DEF
#endif

// extra left thumb keys for non default layers - this includes 1 key for corne, 2 keys for lily, and 3 keys for sofle
#if !defined X_LT_NON_DEF
    #define X_LT_NON_DEF
#endif

#if !defined X_ENC // extra encoder knobs - this includes left and right knobs
    #define X_ENC
#endif
