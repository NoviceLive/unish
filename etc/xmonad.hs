-- The third one.


-- import XMonad
-- import XMonad.Hooks.DynamicLog


-- main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig


-- myBar = "xmobar"


-- myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }


-- toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)


-- myConfig = defaultConfig { modMask = mod4Mask }


-- The second one.


-- import XMonad
-- import XMonad.Hooks.DynamicLog


-- main = xmonad =<< xmobar defaultConfig { modMask = mod4Mask }


-- The first one.


import XMonad (xmonad, defaultConfig, modMask, mod4Mask)


main = xmonad defaultConfig
       { modMask = mod4Mask
       }
