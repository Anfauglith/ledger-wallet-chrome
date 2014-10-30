# A device manager for keeping the devices registry and observing device state.
# It emits events when a wallet is plugged in and when it is unplugged
# @event plug Emitted when the ledger wallet is plugged in
# @event unplug Emitted when the ledger wallet is unplugged
class @DevicesManager extends EventEmitter

  _running: no
  _devicesList: []
  _devices: {}

  constructor: ->
    @cardFactory = new ChromeapiPlugupCardTerminalFactory()

  # Start observing if devices are plugged in or unnplugged
  start: () ->
    return if @_running

    checkIfWalletIsPluggedIn = () ->
      #chrome.usb.getDevices {productId: 0x1b7c, vendorId: 0x2581}, (devices) =>
        #@cardFactory.list_async().then (devices) ->
      self = @
      chrome.usb.getDevices {productId: 0x1b7c, vendorId: 0x2581}, (devices) =>
        l devices
        oldDevices = @_devices
        @_devices = {}
        for device in devices
          device_id = device.device
          l device_id
          if oldDevices[device_id]?
            @_devices[device_id] = oldDevices[device_id]
          else
            @_devices[device_id] = {id: device_id}
        oldDevicesList = _.values(oldDevices)
        devicesList = _.values(@_devices)
        oldDifferences = (item for item in devicesList when _.indexOf(oldDevicesList, item) == -1)
        newDifferences = (item for item in oldDevicesList when _.indexOf(devicesList, item) == -1)
        differences = newDifferences.concat(oldDifferences)
        for difference in differences
          if _.where(oldDevices, {id: difference.id}).length > 0
            @emit 'unplug', difference
          else
            @emit 'plug', difference
            self.stop()
            @cardFactory.list_async().then (result) ->
              l result
              if result.length > 0
                self.cardFactory.getCardTerminal(result[0]).getCard_async().then (card) ->
                  self._devices[difference.id]['lwCard'] = new LW(0, new BTChip(card), self)
                  
                  

            


    @_interval = setInterval checkIfWalletIsPluggedIn.bind(this), 500

  # Stop observing devices state
  stop: () ->
    clearInterval @_interval

  # Get the list of devices
  # @return [Array] the list of devices
  devices: () ->
    devices = []
    for key, device of @_devices
      devices.push device
    devices