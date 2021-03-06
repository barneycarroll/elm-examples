port module Main exposing (..)
import Html exposing (text,pre,div,button,textarea)
import Html.Attributes exposing (class, style,contenteditable,id)
import Html.Events exposing (onClick,on)
import String
import Grid
import Html.App as App
import Json.Decode exposing (string)
import Regex


{-- code which detects lines and connections
also algorithmn to connect these lines
--}

type alias Model =
 {grid: Grid.Model
 }

type Msg = Input String | Convert


init: (Model, Cmd Msg)
init  =
    ({grid = Grid.init arg
     }
    ,Cmd.batch[
        setAsciiText arg
    ]
    )

textContentDecoder =
  Json.Decode.at ["target", "textContent"] string



view model =
    div [style 
            [("display", "flex")
            ]
        ]
        [
        div[] 
           [button [onClick Convert
                   ] 
                   [text "Convert >>"]
           ]
        ,div 
            [style [("width", "500px")
                   ,("height", "100%")
                   ,("overflow", "auto")
                   ]
            ]
            [Grid.getSvg model.grid
            ]
        ]

    {--
    div []
        [
        button [
                style [("padding","10px")
                      ,("margin-left","500px")
                      ]
                ,onClick Convert
               ] 
               [text "Convert >>"]
        ,div [style [("display", "flex")]]
            [pre 
                [style 
                    [("font-size", "15.4px")
                    ,("font-family","monospace")
                    ,("word-wrap","nowrap")
                    ,("overflow", "auto")
                    ,("border", "1px solid #ddd")
                    ,("min-height", "500px")
                    ,("min-width", "500px")
                    ]
                  ,contenteditable True
                  ,id "ascii_text" 
                  ,on "input" (Json.Decode.map Input textContentDecoder)
                 ]
                 [text arg]
            ,div [style [("padding-left", "10px")]]
                [Grid.getSvg model.grid
                ]
            ]
        ]
    --}

        
update msg model =
    case msg of
        Convert ->
            (model, getAsciiText () )
        Input asciiText ->
            ({model | grid = Grid.init asciiText}
            ,Cmd.none
            )

main =
    App.program
    {init = init
    ,view = view
    ,update = update
    ,subscriptions = subscriptions
    }

subscriptions: Model -> Sub Msg
subscriptions model =
    Sub.batch [receiveAsciiText Input]

port getAsciiText: () -> Cmd msg

port setAsciiText: String -> Cmd msg

port receiveAsciiText: (String -> msg) -> Sub msg




arg = 
    """

+------+   +-----+   +-----+   +-----+
|      |   |     |   |     |   |     |
| Foo  +-->| Bar +---+ Baz |<--+ Moo |
|      |   |     |   |     |   |     |
+------+   +-----+   +--+--+   +-----+
              ^         |
              |         V
.-------------+-----------------------.
| Hello here and there and everywhere |
'-------------------------------------'


                        ____________
   .--------------.     \\           \\
  / a == b         \\     \\           \\     __________
 (    &&            )     ) process   )    \\         \\
  \\ 'string' ne '' /     /           /     / process /
   '--------------'     /___________/     /_________/

  User code  ^               ^ OS code
              \\             /
               \\        .--'
                \\      /
  User code  <--- Mode ----> OS code
                /      \\
            .--'        \\___
           /                \\
          v                  v 
       User code            OS code

             .---.  .---. .---.  .---.    .---.  .---.
    OS API   '---'  '---' '---'  '---'    '---'  '---'
               |      |     |      |        |      |
               v      v     |      v        |      v
             .------------. | .-----------. |  .-----.
             | Filesystem | | | Scheduler | |  | MMU |
             '------------' | '-----------' |  '-----'
                    |       |      |        |
                    v       |      |        v
                 .----.     |      |    .---------.
                 | IO |<----'      |    | Network |
                 '----'            |    '---------'
                    |              |         |
                    v              v         v
             .---------------------------------------.
             |                  HAL                  |
             '---------------------------------------'
             

   ____[]
  | ___ |
  ||   ||  device
  ||___||  loads
  | ooo |----------------------------------------------------------.
  | ooo |    |                          |                          |
  | ooo |    |                          |                          |
  '_____'    |                          |                          |
             |                          |                          |
             v                          v                          v
   .-------------------.  .---------------------------.  .-------------------.
   | Loadable module C |  |     Loadable module A     |  | Loadable module B |
   '-------------------'  |---------------------------|  |   (instrumented)  |
             |            |         .-----.           |  '-------------------'
             '------------+-------->| A.o |           |             |
                 calls    |         '-----'           |             |
                          |    .------------------.   |             |
                          |   / A.instrumented.o /<---+-------------'
                          |  '------------------'     |    calls
                          '---------------------------'   


                                        .--> Base::Class::Derived_A
                                       /
                                      .----> Base::Class::Derived_B    
      Something -------.             /         \\
                        \\           /           \\---> Base::Class::Derived
      Something::else    \\         /             \\
            \\             \\       /               '--> Base::Class::Derived
             \\             \\     /
              \\             \\   .-----------> Base::Class::Derived_C 
               \\             \\ /
                '------ Base::Class
                       /  \\ \\ \\
                      '    \\ \\ \\  
                      |     \\ \\ \\
                      .      \\ \\ '--- The::Latest
                     /|       \\ \\      \\
 With::Some::fantasy  '        \\ \\      '---- The::Latest::Greatest
                     /|         \\ \\
         More::Stuff  '          \\ '- I::Am::Running::Out::Of::Ideas
                     /|           \\
         More::Stuff  '            \\
                     /              '--- Last::One
         More::Stuff 

  Safety
    ^
    |                       *Rust
    |           *Java
    | *Python
    |                        *C++
    +-----------------------------> Control





  TODO:

   

        |   \\/   
       -+-  /\\      
        |   
        
        |      |    |      |
        +--  --+    +--  --+   +--  --+
                    |      |   |      |

                     |    |  |     |
             .- -.   .-  -.  ._   _.
             |   |

        .-   -.  .-.       
        '-   -'  | |  | |  
                      '-'

      \\      |    /  |
       .     '   '   .
       |    /    |    \\ 

       \\
       /

       /
       \\


       /      \\
      '--    --'
     /          \\

       /   \\
    --'     '--
     /       \\

                       \\         /
       --.--  --.--   --.--   --.--
        /        \\     


        |   |
        .   .
       /|   |\\ 

        |
        .
       / \\

       \\|/
        .
       /|\\

       
       \\|/
      --.--
       /|\\

       \\|/
      --+--
       /|\\
        
        |/  \\|
        .    .
        |    |


       -.  -.
       /     \\

        .-  .-
       /     \\

      
       /   /     \\    \\
      '-  '_     _'   -'
       

       .-.
      (   )
       '-'

       ..
      (  )
       ''


       .------.
      (        )
       '------'

        ________  
       /       /
      /       /
     /_______/


        ________  
        \\       \\
         \\       \\
          \\_______\\

       ________ 
      |________|


       ________ 
      |        |
      |________|

      .-.
      '-'

        ________  
        \\_______\\

       /\\
      /  \\
     /____\\

       /\\
      /  \\
     /    \\
    '------'

       ___
      /   \\
      \\___/

      ______
     /      \\
    /        \\
    \\        /
     \\______/
        

        +---------+
        |         |                        +--------------+
        |   NFS   |--+                     |              |
        |         |  |                 +-->|   CacheFS    |
        +---------+  |   +----------+  |   |  /dev/hda5   |
                     |   |          |  |   +--------------+
        +---------+  +-->|          |  |
        |         |      |          |--+
        |   AFS   |----->| FS-Cache |
        |         |      |          |--+
        +---------+  +-->|          |  |
                     |   |          |  |   +--------------+
        +---------+  |   +----------+  |   |              |
        |         |  |                 +-->|  CacheFiles  |
        |  ISOFS  |--+                     |  /var/cache  |
        |         |                        +--------------+
        +---------+
    """

