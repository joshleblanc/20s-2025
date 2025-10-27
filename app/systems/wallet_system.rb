class WalletSystem 
    def call(args)
        args.state.entities.each_entity(:wallet) do |entity_id, wallet|
            rect = args.layout.rect(row: 0, col: 23, w: 1, h: 1)
            args.outputs.labels << rect.center.merge(text: wallet.cash.to_s, anchor_x: 0.5, anchor_y: 0.5)
        end
    end
end