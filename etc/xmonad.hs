import XMonad
import XMonad.Hooks.DynamicLog


main = xmonad =<< xmobar defaultConfig { modMask = mod4Mask }


-- import XMonad (xmonad, defaultConfig, modMask, mod4Mask)


-- main = xmonad defaultConfig
--        { modMask = mod4Mask
--        }
