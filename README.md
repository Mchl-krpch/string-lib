# string-lib - second project on asm ![settings](https://raw.githubusercontent.com/Mchl-krpch/string-lib/dc90e869b218684f7e81aacee008b82f5a2c4a51/visual/settings-svgrepo-com.svg)

💻 Implementation of `well-known functions` but in a different language. Functions have already been written here that use registers and change their values, that is, the use of such functions may `affect` the operation of other elements of the project, so you need to use them carefully

## Essence of the project

My second assembly language project, implemented `standard string functions` from `C`, such as
* strlen - essence of the project
* strcmp - compare strings lexicographically
* strchr - find a character in a string
* strcpy - copy a string to another string

## Process

![img](https://raw.githubusercontent.com/Mchl-krpch/string-lib/main/visual/wrapper-poster.jpg)

Commands like [scasb](http://www.club155.ru/x86cmd/SCASB) helped me a lot, this makes the functions look extremely `short` this project, unlike the first one, was written extremely `quickly`

## New info
* scasb - compares value es:[di] with al
* loop  - repeats some action until cx is reset to zero
* stosw - copys    value ax to es:[di]
* smpsb - compares value ds:[si] with es:[di]
* movsb - writes   ds:[si] to es:[di]

## Thanks!
I will be glad to your `issue`

Krapchatov Michael, 22


