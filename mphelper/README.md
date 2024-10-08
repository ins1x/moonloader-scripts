<h1 align="center">MP Helper</h1>
<p align="center">
    <a href="https://www.sa-mp.mp/"><img src="https://img.shields.io/badge/made%20for-GTA%20SA--MP-blue"></a>
     <a href="https://training-server.com/"><img src="https://img.shields.io/badge/Server-TRAINING%20SANDBOX%20-yellow"></a>
    <a href="https://gta-samp.ru/"><img src="https://img.shields.io/badge/Server-Absolute%20Play-red"></a>
</p>

###### The following description is in Russian, because it is the main language of the user base.

![logo](https://github.com/ins1x/moonloader-scripts/raw/main/mphelper/moonloader/resource/mphelper/demo.gif)

### Краткое описание скрипта
Хелпер предназначен для организаторов мероприятий. Содержит множество функций для подготовки и проведения мероприятий в SA:MP.
Потенциально читерские возможности не используются - это не мультичит!   

Скрипт предназанчен для [TRAINING SANDBOX](https://training-server.com/) и [Absolute Play](https://sa-mp.ru/). Может работать и на других проектах, но некоторый функционал может быть недоступен. 

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
- Вам потребуется рабочая копия игры GTA San Andreas с верисей gta_sa.exe v1.0 US
- [ASI Loader](https://www.gtagarage.com/mods/show.php?id=21709), [CLEO 4.1](https://cleo.li/ru)+, [Moonloader 0.26](https://www.blast.hk/threads/13305/), [SAMPFUNCS 5.4.1](https://www.blast.hk/threads/17/)+

> Можно использовать более новые версии клиента и sampfuncs, но часть функционала построенного на мемхаках работать не будет (например смена эффектов)

Зависимости Moonloader:
* lua imgui - https://www.blast.hk/threads/19292/
* lib.samp.events - https://github.com/THE-FYP/SAMP.Lua

## Установка

Скачайте актуальную версию и скопируйте содержимое в папку **moonloader** в корне игры. Важно перенести все файлы, включая папки /config и /resource ! 

<!-- [![GitHub](https://img.shields.io/badge/DOWNLOAD%20-696969?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ins1x/moonloader-scripts/blob/main/mphelper/mphelper.lua) -->
[![Google Drive](https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/drive/folders/1dfDp-OkhLMfO8O8Mkll7VLgCtgzaTlqW?usp=drive_link)

> Если у вас нет папки **moonloader** в корне игры, следует установить вышеописанные в  требованиях компоненты.

После установки запустите игру и подключитесь к серверу  
В игре нажмите **ALT + E** или введите команду **/mphelper**

## Конфигурация

### Общие настройки 
Большинство настроек скрипта можно менять здесь.
```INI
[settings]
menukey=45                  Клавиша для вызоа меню по-умолчанию
playerwarnings=false        Включить варнинги на игроков
disconnectreminder=false    Уведомлять при выходе игроков из списка на МП
menukeychanged=false        Активировать изменение горячей клавиши для вызова главного меню

```

### Настройки биндов
Хранят в себе текстовую информацию о пользовательских командах (биндах). Используется для текстовых команд в чат.  
(Ограничены количеством 9 штук)  
```INI
[binds]
cmdbind1=Произвольный текст либо команда
```

### Настройки варнингов  
Выводит предупреждения на подозрительных игроков. Варнинги работают если включена опция playerwarnings в секции [settings].  

```INI
[warnings]
afk=true                    Проверяет АФК игроков
armourrefill=true           Проверяет пополнение брони
heavyweapons=true           Проверяет наличие тяжелого оружия у игрока в руках
hprefill=true               Проверяет пополнение хп
illegalweapons=true         Проверяет на запрещенное оружие (сперва нужно будет указать какое разрешено)
laggers=true                Проверяет на лаги (по пингу)
undermap=true               Проверяет не под картой ли игрок
```

### Настройка сайдбара
Выводит над радаром полезную информацию. На данный момент только игроков в стриме.

```INI
[sidebar]
fontname="Tahoma"           Шрифт рендера
fontsize=7                  Размер шрифта на рендере
maxlines=10                 Максимально количество линий для отображения
mode=0                      Режим (зарезервировано, пока не используется)
x=15                        Позиция по оси X
y=400                       Позиция по оси Y  
```

### О поддержке SAMP ADDON (для игроков Absolute Play)
Скрипт не работает с включенным античитом Samp Addon (ничего не мешает Вам поставить хелпер в свою сборку без аддона или отключить античит).
Чтобы компенсировать недостающие от SAMP ADDON функции воспользуйтесь [AbsoluteFix](https://github.com/ins1x/useful-samp-stuff/tree/main/luascripts/absolutefix) - это набор исправлений и дополнений для серверов Absolute Play.
Скрипт не содержит запрещенных функций, и вы можете его использовать не опасаясь попадания в читмир. Все вышеописанное относится только к серверам Absolute Play.  

> Если скрипт не запустился, в папке moonloader есть файл moonloader.log с информацией о проблеме 
