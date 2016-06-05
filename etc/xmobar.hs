Config { font = "SourceCodePro 10"
       , additionalFonts = []
       , borderColor = "red"
       , border = BottomB
       , bgColor = "black"
       , fgColor = "green"
       , alpha = 255
       , position = Top
       , textOffset = -1
       , iconOffset = -1
       , lowerOnStart = True
       , pickBroadest = False
       , persistent = False
       , hideOnStart = False
       , iconRoot = "."
       , allDesktops = True
       , overrideRedirect = False
       , commands = [
           Run Network "wlp3s0" ["-L","0","-H","32"
                                , "--normal","green"
                                , "--high","red"] 10
           , Run Cpu ["-L","3","-H","50"
                     , "--normal","green","--high","red"] 10
           , Run Memory ["-t","Memory: <usedratio>%"] 10
           , Run Swap [] 10
           , Run Com "uname" ["-s", "-r"] "" 36000
           , Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
           ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%cpu% | %memory% | %swap% | %wlp3s0% }{ <fc=#ff0000>%date%</fc> | %uname%"
       }
