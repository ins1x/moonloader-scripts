<h1 align="center">MP Helper</h1>
<p align="center">
    <a href="https://www.sa-mp.mp/"><img src="https://img.shields.io/badge/made%20for-GTA%20SA--MP-blue"></a>
     <a href="https://training-server.com/"><img src="https://img.shields.io/badge/Server-TRAINING%20SANDBOX%20-yellow"></a>
    <a href="https://gta-samp.ru/"><img src="https://img.shields.io/badge/Server-Absolute%20Play-red"></a>
</p>

###### The following description is in Russian, because it is the main language of the user base.

![logo](https://github.com/ins1x/moonloader-scripts/tree/main/absolute-play/mphelper/moonloader/resource/mphelper/demo.gif)

### Краткое описание скрипта
Хелпер предназначен для организаторов мероприятий. Содержит множество функций для подготовки и проведения мероприятий в SA:MP.
Потенциально читерские возможности не используются - это не мультичит!   

Скрипт поддерживается для [Absolute Play](https://sa-mp.ru/) и [TRAINING SANDBOX](https://training-server.com/). Может работать и на других проектах, но некоторый функционал может быть недоступен. 

### Возможности
- Удобные меню для подготовки, управления и завершения МП
- Отображение текущего сервера, времени и времени запуска МП
- Авто-отправка всех заданных правил в чат
- Авто-анонс мероприятия в объявления
- Сохранение списка игроков на мероприятии (даже при вылете список игроков у вас сохранится в папке со скриптом)
- Шаблоны для быстрых ответов игрокам /ответ
- Выбор капитанов из случайного игрока, либо игрока с наибольшим уровнем
- Возможность указать спонсоров мероприятия
- Сообщение если из таблицы игроков кто-то вылетел или вышел из игры
- Статистика по игрокам онлайн
- Черный список игроков
- Быстрые команды с биндами для МП
- Проверка игроков (поиск афкашников, лагеров, с оружием и.т.д)
- Меню для быстрого управления игроками в мире
- Варнинги на подозрительных игроков (лагеры, с нелегальным оружием, пополнение хп и брони, нахождение под текстурами)
- Текстовые игры с чатом (Крокодил, Викторина и.т.д)

## Требования
- [ASI Loader](https://www.gtagarage.com/mods/show.php?id=21709), [CLEO 4.1](https://cleo.li/ru)+, [Moonloader 0.26](https://www.blast.hk/threads/13305/), [SAMPFUNCS 5.4.1](https://www.blast.hk/threads/17/)+

> Можно использовать более новые версии клиента и sampfuncs

Зависимости Moonloader:
* lua imgui - https://www.blast.hk/threads/19292/
* lib.samp.events - https://github.com/THE-FYP/SAMP.Lua
* lua-requests - https://luarocks.org/modules/jakeg/lua-requests

> модуль **lua-requests** используется только для проверки версий, поэтому установка этого модуля необязательна для работы скрипта

## Установка

Скачайте актуальную версию и скопируйте содержимое в папку **moonloader** в корне игры. Важно перенести все файлы, включая папки /config и /resource ! 

<!-- [![GitHub](https://img.shields.io/badge/DOWNLOAD%20-696969?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ins1x/moonloader-scripts/blob/main/mphelper/mphelper.lua) -->
[![Google Drive](https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/drive/folders/1dfDp-OkhLMfO8O8Mkll7VLgCtgzaTlqW?usp=drive_link)

> Если у вас нет папки **moonloader** в корне игры, следует установить вышеописанные в  требованиях компоненты.

После установки запустите игру и подключитесь к серверу  
В игре нажмите **ALT + E** или введите команду **/mphelper**

### О поддержке SAMP ADDON (для игроков Absolute Play)
Скрипт не работает с включенным античитом Samp Addon (ничего не мешает Вам поставить хелпер в свою сборку без аддона или отключить античит).
Чтобы компенсировать недостающие от SAMP ADDON функции воспользуйтесь [AbsoluteFix](https://github.com/ins1x/moonloader-scripts/tree/main/absolute-play/absolutefix) - это набор исправлений и дополнений для серверов Absolute Play.
Скрипт не содержит запрещенных функций, и вы можете его использовать не опасаясь попадания в читмир. Все вышеописанное относится только к серверам Absolute Play.  

> Если скрипт не запустился, в папке moonloader есть файл moonloader.log с информацией о проблеме 
