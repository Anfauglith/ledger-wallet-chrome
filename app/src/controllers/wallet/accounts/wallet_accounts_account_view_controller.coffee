class @WalletAccountsAccountViewController extends @ViewController

  showOperation: (params) ->
    dialog = new WalletOperationsDetailDialogViewController(params)
    dialog.show()

  onAfterRender: ->
  	ledger.application.devicesManager.on 'LWWallet.BalanceRecovered', (event, data) ->
      l "BALANCE !"
    l @select('#unconfirmed_balance_tooltip')
    @select('#unconfirmed_balance_tooltip').tooltipster
      content: 'Hello world'
      theme: 'tooltipster-light'