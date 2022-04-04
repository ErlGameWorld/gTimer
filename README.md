gTimer
=====
    多工作进程的全局定时器


Build
-----

    $ rebar3 compile

Useage
-----
    startWork/1     开启指定数量的定时器工作者
    setTimer/2      随机一个定时器工作者然后设置定时器    
    setTimer/3      指定选择定时器工作者策略然后设置定时器  
    getTimer/1      获取定时器的信息
    delTimer/1      删除一个定时器
