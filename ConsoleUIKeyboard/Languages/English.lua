local Language = ConsoleUIKeyboardNS

-- [1] Shift  [2] none  [3] Ctrl symbols  [4] Ctrl+Shift channels + phrases
Language.English = {
    [1] = {
        {"A", "a", "1", "/s "},
        {"B", "b", "2", "/p "},
        {"C", "c", "3", "/g "},
        {"D", "d", "4", "/y "},
    },
    [2] = {
        {"E", "e", "5", "/w "},
        {"F", "f", "6", "/e "},
        {"G", "g", "7", "/r "},
        {"H", "h", "8", "/ra "},
    },
    [3] = {
        {"I", "i", "9", "/rw "},
        {"J", "j", "0", "/o "},
        {"K", "k", "-", "/readycheck "},
        {"L", "l", "=", "%T "},
    },
    [4] = {
        {"M", "m", "!", "Thank you"},
        {"N", "n", "?", "You're welcome"},
        {"O", "o", ".", "Sorry"},
        {"P", "p", ",", "Please"},
    },
    [5] = {
        {"Q", "q", "'", "Wait for me"},
        {"R", "r", "\"", "On my way"},
        {"S", "s", ";", "Follow me"},
        {"T", "t", ":", "Can you help me"},
    },
    [6] = {
        {"U", "u", "(", "Incoming"},
        {"V", "v", ")", "Heal please"},
        {"W", "w", "[", "Out of mana"},
        {"X", "x", "]", "Invite please"},
    },
    [7] = {
        {"Y", "y", "{", "Be right back"},
        {"Z", "z", "}", "AFK"},
        {"\"", "'", "/", "I'm back"},
        {"_", "-", "\\", "One moment"},
    },
    [8] = {
        {"!", "!", "+", "Looking for group "},
        {":", ".", "_", "Hello"},
        {";", ",", "*", "Ready"},
        {"?", "?", "&", "Summon please"},
    },
}
