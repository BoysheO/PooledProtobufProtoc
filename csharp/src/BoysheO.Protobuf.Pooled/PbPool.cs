using System;
using Google.Protobuf;

namespace BoysheO.Protobuf.Pooled
{
    public sealed class PbPool<T>
        where T : IBufferMessage, IMessage<T>, new()
    {
        private static readonly global::System.Collections.Concurrent.ConcurrentBag<T> _pool =
            new global::System.Collections.Concurrent.ConcurrentBag<T>();

        public static T Rent()
        {
            return _pool.TryTake(out var ins) ? ins : new T();
        }

        public static void Return(T ins)
        {
            if (ins == null) throw new ArgumentNullException(nameof(ins));
            _pool.Add(ins);
        }
    }
}