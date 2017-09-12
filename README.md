# -codeless-usinglog
================================================================================
采用runtime的特性，进行app的无埋点采集页面活动信息（全采集）
-------------------------------------------------------- 
若有所针对，可以在Usinglog文件下的UIViewController+Usinglog.m中
```
if ([ELActivityAgent getInstance].interruptActivityLog
&&![NSStringFromClass([self class]) isEqualToString:@"UINavigationController"]
&&![NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]进行过滤、
```

使用方式
-------------------------------------------------------- 
仅需在appdelegate中插入
```
[[ELActivityAgent getInstance] startAgent];
```
即可

自定义采集数据
-------------------------------------------------------- 
ELActivityLog在这个类中，添加要采集的数据的，并且在ELActivityDao中对数据的操作加上新采集的数据，在UIViewController+Usinglog进行数据的赋值

数据接收的nginx或者其他服务的地址修改
-------------------------------------------------------- 
在ELActivityDao.m中
```
//修改您的nginx地址
[ELActivityAgent postData:@"nginx地址" data:finalDic];
```
