import XMonad (xmonad, defaultConfig, modMask, mod4Mask)


main = xmonad defaultConfig
       { modMask = mod4Mask
       }
