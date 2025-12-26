local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return self
end

function Signal:Connect(func)
    assert(typeof(func) == "function", "Argument must be a function")
    local listener = {callback = func, disconnected = false}
    table.insert(self._listeners, listener)

    return {
        Disconnect = function()
            listener.disconnected = true
        end
    }
end

function Signal:Fire(...)
    local listeners = self._listeners
    local i = 1
    while i <= #listeners do
        local listener = listeners[i]
        if listener.disconnected then
            table.remove(listeners, i)
        else
            listener.callback(...)
            i = i + 1
        end
    end
end

function Signal:DisconnectAll()
    self._listeners = {}
end

return Signal
