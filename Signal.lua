Signal = {
    new = function()
        local self = {
            _connections = {},
            _destroyed = false
        }

        function self:Connect(callback)
            assert(type(callback) == "function", "callback must be a function")
            local conn = {
                Connected = true,
                _callback = callback,
                _signal = self
            }

            function conn:Disconnect()
                if not self.Connected then return end
                self.Connected = false

                for i, c in ipairs(self._signal._connections) do
                    if c == self then
                        table.remove(self._signal._connections, i)
                        break
                    end
                end

                self._signal = nil
                self._callback = nil
            end

            table.insert(self._connections, conn)
            return conn
        end

        function self:Fire(...)
            if self._destroyed then return end

            -- Safe copy to avoid mutation during iteration
            local list = {}
            for i = 1, #self._connections do
                list[i] = self._connections[i]
            end

            for _, conn in ipairs(list) do
                if conn.Connected then
                    local ok, err = pcall(conn._callback, ...)
                    if not ok then
                        warn("Signal error:", err)
                    end
                end
            end
        end

        function self:Wait()
            local thread = coroutine.running()
            local temp
            temp = self:Connect(function(...)
                temp:Disconnect()
                coroutine.resume(thread, ...)
            end)
            return coroutine.yield()
        end

        function self:Destroy()
            if self._destroyed then return end
            self._destroyed = true

            for _, conn in ipairs(self._connections) do
                if conn.Connected then
                    conn:Disconnect()
                end
            end

            self._connections = {}
        end

        return self
    end
}
