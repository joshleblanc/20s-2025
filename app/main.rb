require "joshleblanc/drecs/drecs"
require "app/systems/stock_price_update_system"
require "app/systems/render_rects_system"
require "app/systems/render_text_system"
require "app/systems/hoverable_system"
require "app/systems/handle_click_system"
require "app/systems/timer_system"
require "app/systems/wallet_system"
require "app/systems/graph_system"

STOCKS = ["MEME", ]#"DRRB", "GODS", "HAPP"]
VOLATILITIES = ["steady", "rollercoaster", "pump_dump", "late_bloomer", "fake_out"]
    
SYSTEMS = [
    StockPriceUpdateSystem.new,
    RenderRectsSystem.new,
    RenderTextSystem.new,
    HoverableSystem.new,
    HandleClickSystem.new,
    TimerSystem.new,
    WalletSystem.new,
    GraphSystem.new
]

def tick(args)
    if args.state.tick_count == 0 
        init(args)
    end

    SYSTEMS.each { |system| system.call(args) }
end

def init(args)
    args.state.entities = Drecs::World.new
    #args.outputs.static_primitives << Layout.debug_primitives

    spawn_menu_entities(args)
end

def spawn_menu_entities(args)
    args.state.entities.spawn(
        rect: args.layout.rect(row: 6, col: 11, w: 4, h: 2),
        text: "Play",
        hoverable: true,
        on_click: ->(args) { spawn_game_entities(args) }
    )

    args.state.entities.spawn(
        rect: args.layout.rect(row: 8, col: 11, w: 4, h: 2),
        text: "Exit",
        hoverable: true
    )
end

def spawn_game_entities(args)
    # remove menu
    args.state.entities.destroy(*args.state.entities.query.to_a.flatten)

    args.state.entities.spawn({
        wallet: {
            cash: 1000,
            starting_cash: 1000
        }
    })

    args.state.entities.spawn({
        timer: {
            tick_count_at_start: args.state.tick_count,
            duration: 20,
            current_seconds: 0,
            ticks_per_second: 60 # this is stupid, I want delta time
        }
    })

    STOCKS.each_with_index do 
        args.state.entities.spawn({
            stock: {
                symbol: _1,
                current_price: Numeric.rand(10..50),
                base_price: Numeric.rand(10..50),
                volatility_type: VOLATILITIES.sample,
                seed: rand(1000)
            },
            price_history: {
                history: [],
                max_history: 100,
                update_frequency: 20
            },
            rect: args.layout.rect(row: 1 + ((_2 % 3) * 3), col: 1 + (_2 / 3).floor * 10, w: 10, h: 3),
            graph: true
        })
    end
end