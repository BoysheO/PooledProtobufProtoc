# 池化的protoc方案（支持OdinInspector版）

讨论群：1054976810

## 使用方法


下载所需的protoc来替换原来的protoc：

二进制Protoc下载

|platform|bin|
|--|--|
|macOs M1|进群领取| 
|Windows(x64)|进群领取|
|Linux|进群领取|

可以自己动手编译，编译步骤与官方文档相同。

然后复制以下文件夹中的C#代码到你的C#工程中，和protoc生成的代码放在一起编译

[csharp\src\BoysheO.Protobuf.Pooled](csharp\src\BoysheO.Protobuf.Pooled)

ok，你已就绪。接下来，你需要在你的程序中，在调用任何ProtobufMessage前，设置好工厂上下文。

推荐使用预先实现的池化工厂（必须在调用任何ProtobufMessage前调用，否则抛异常）
预先实现的池化工厂是线程安全的。

```C#
//本代码线程安全
    ProtobufFactoryContext.UsePooledFactoryProvider();
```

使用上述预先实现的池化工厂时，每当你使用完毕一个ProtobufMessage之后，可以将其回收：

```C#
//本代码线程安全
    PbMsg ins = new PbMsg();
    PbPool<PbMsg>.Return(ins);
```

当然，预先实现的对象池是公开的，支持以下API

```C#
//本代码线程安全
    var ins = PbPool<PbMsg>.Rent();
```

当你不再使用池化方案时，你可以改用原始protoc来生成Pb消息。这样的话，protobufMessage将不再使用ProtobufFactoryContext来初始化工厂。你的代码基本无需变化即可切换到非池化的状态。

## 使用预先实现的池化工厂的注意事项


本库主要为Unity等gc效能低下的运行环境设计，特别适用于使用了grpc作为网络通信协议的项目。在gc效能高的运行环境下，池化意义不大，因此不建议在服务器端使用本库。

## 如何自定义工厂


如果你不想使用预先实现的池化方案，也可以实现自己的工厂方法。必须在调用任何ProtobufMessage前调用,否则抛异常.

```C#
//本代码线程安全，且本API仅可调用1次
    ProtobufFactoryContext.SetFactoryProvider(new CustomProtobufFactoryProvider());
```

也可以直接改写ProtobufFactoryContext的GetFactory函数，在不好管理SetFactoryProvider生命周期时，改写代码也是推荐的方法之一！

## 备注：protoc具体改进的地方


原来protoc生成的默认new工厂方法，现在变成了由上下文提供

Before

```C#
public sealed partial class OpenSteamRet : pb::IMessage<OpenSteamRet>
  {
    private static readonly pb::MessageParser<OpenSteamRet> _parser = new pb::MessageParser<OpenSteamRet>(() => new OpenSteamRet());
    ...
  }
```

After:

```C#
public sealed partial class OpenSteamRet : pb::IMessage<OpenSteamRet>
  {
    private static readonly pb::MessageParser<OpenSteamRet> _parser = new pb::MessageParser<OpenSteamRet>(global::BoysheO.Protobuf.Pooled.ProtobufFactoryContext.GetFactory<OpenSteamRet>());
    ...
  }
```
