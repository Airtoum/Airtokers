--- STEAMODDED HEADER
--- MOD_NAME: Airtokers
--- MOD_ID: Airtokers
--- MOD_AUTHOR: [Airtoum]
--- MOD_DESCRIPTION: Adds some jokers
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: 665A88
--- PREFIX: toum

----------------------------------------------
------------MOD CODE -------------------------

local Airtokers = SMODS.current_mod

local function primitive_math_sign(n)
    return (n < 0 and -1) or 1
end

local function number(n)
    if to_big then
        local return_n
        if Big.array and type(n) == 'number' then 
            return_n = to_big({n}, primitive_math_sign(n))
        else
            return_n = to_big(n)
        end
        --if return_n.normalize then return return_n:normalize() end
        --if return_n.normalized then return return_n:normalized() end
        local array = return_n.array
        local array_1 = array and array[1] or nil
        local sign = return_n.sign
        local e = return_n.e
        local m = return_n.m
        --assert(array_1 == 30, 'array_1 was not 30')
        --assert(false, 'assertion did not fail')
        return return_n
    end
    return n
end
Airtokers.number = number

local function primitive_number(n)
    if type(n) == 'table' then return n:to_number() end
    return n
end

local function identity(x)
    return x
end

local function is_big(x)
    return (type(x) == 'table') and ((x.e and x.m) or (x.array and x.sign))
end
Airtokers.is_big = is_big

local function number_equal(a, b)
    if is_big(a) then
        return a:eq(b)
    end
    return a == b
end
Airtokers.number_equal = number_equal

local function is_zero(a)
    return number_equal(a, number(0))
end
Airtokers.is_zero = is_zero

local function is_positive(a)
    if is_big(a) and a.is_positive then
        return not is_zero(a) and a:is_positive()
    end
    return a > number(0)
end
Airtokers.is_positive = is_positive

local function is_negative(a)
    if is_big(a) and a.is_negative then
        return a:is_negative()
    end
    return a < number(0)
end
Airtokers.is_negative = is_negative

local function number_not_equal(a, b)
    if is_big(a) then
        return not a:eq(b)
    end
    return a ~= b
end
Airtokers.number_not_equal = number_not_equal

local function number_greater_than(a, b)
    if is_big(a) then
        return a:gt(b)
    end
    return a > b
end
Airtokers.number_greater_than = number_greater_than

local function number_less_than(a, b)
    if is_big(a) then
        return a:lt(b)
    end
    return a < b
end
Airtokers.number_less_than = number_less_than

-- bignum favors the number with the higher exponent, and ranges 0-1 have negative exponents, where 0 has exponent of 0. We must handle 0 specifically
local function number_greater_than_or_equal(a, b)
    --if number_equal(a, b) then return true end
    if is_big(a) then
    --    if is_zero(a) then return is_negative(b) end
    --    if is_zero(b) then return is_positive(a) end
        return a:gte(b)
    end
    return a >= b
end

local function number_less_than_or_equal(a, b)
    --if number_equal(a, b) then return true end
    if is_big(a) then
    --    if is_zero(a) then return is_negative(b) end
    --    if is_zero(b) then return is_positive(a) end
        return a:lte(b)
    end
    return a <= b
end

local function number_round_towards_positive_infinity(a)
    if is_big(a) then
        if a.floor then return (a - number(0.5)):floor() + number(1) end
        if a.round then return a:round() end
    end 
    return math.floor(a - number(0.5)) + number(1) -- number() just in case somehow
end

local function number_abs(a)
    if is_positive(a) then
        return a
    else
        return a * number(-1)
    end
end

local function velocitize(n, naked_zero)
    if is_positive(n) then
        return '+'..format_ui_value(n)
    elseif is_negative(n) then
        return '-'..format_ui_value(n)
    elseif naked_zero then
        return format_ui_value(n)
    else
        return '+'..format_ui_value(n)
    end
end

-- sanity checks

if false then

    assert(number(5) == number(5))
    assert(number(5) + number(5) == number(10))
    assert(number(10) == number(5) + number(5))
    assert(number(5) * number(5) == number(25))
    print(number(5), number(5) ^ number(5), number(3125), number(5) ^ number(5) == number(3125))
    print(inspect(number(5) ^ number(5)), inspect(number(3125)))
    print(getmetatable(number(5) ^ number(5)), getmetatable(number(3125)), getmetatable(number(5) ^ number(5)) == getmetatable(number(3125)))
    print(getmetatable(number(5) ^ number(5)).__eq, getmetatable(number(3125)).__eq, getmetatable(number(5) ^ number(5)).__eq == getmetatable(number(3125)).__eq)
    assert(number(5) ^ number(5) == number(3125))

    assert(not number(5) == number(10))
    assert(not number(5) == number(0))
    assert(not number(5) == number(-10))

    assert(number(5) ~= number(10))
    assert(number(5) ~= number(0))
    assert(number(5) ~= number(-10))

    assert(number(0) == number(0))

    assert(number(5) - number(5) == number(0))
    assert(number(5) / number(5) == number(1))
    assert(number(9) ^ number(0.5) == number(3))

    if type(number(5)) == 'table' then
        assert(number(25):log(number(5)) == number(2))
    else
        assert(math.log(number(25), number(5)) == number(2))
    end

    -- lhs 10

    assert(not number(10) > number(10))
    assert(number(10) > number(5))
    assert(number(10) > number(0))
    assert(number(10) > number(-5))

    assert(number(10) >= number(10))
    assert(number(10) >= number(5))
    assert(number(10) >= number(0))
    assert(number(10) >= number(-5))

    assert(not number(10) < number(10))
    assert(not number(10) < number(5))
    assert(not number(10) < number(0))
    assert(not number(10) < number(-5))

    assert(number(10) <= number(10))
    assert(not number(10) <= number(5))
    assert(not number(10) <= number(0))
    assert(not number(10) <= number(-5))

    -- rhs 10

    assert(not number(10) > number(10) )
    assert(not number(5) > number(10) )
    assert(not number(0) > number(10) )
    assert(not number(-5) > number(10) )

    assert(number(10) >= number(10) )
    assert(not number(5) >= number(10) )
    assert(not number(0) >= number(10) )
    assert(not number(-5) >= number(10) )

    assert(not number(10) < number(10) )
    assert(number(5) < number(10) )
    assert(number(0) < number(10) )
    assert(number(-5) < number(10) )

    assert(number(10) <= number(10) )
    assert(number(5) <= number(10) )
    assert(number(0) <= number(10) )
    assert(number(-5) <= number(10) )

    -- lhs 1

    assert(not number(1.0) > number(1.0))
    assert(number(1.0) > number(.5))
    assert(number(1.0) > number(.0))
    assert(number(1.0) > number(-.5))

    assert(number(1.0) >= number(1.0))
    assert(number(1.0) >= number(.5))
    assert(number(1.0) >= number(.0))
    assert(number(1.0) >= number(-.5))

    assert(not number(1.0) < number(1.0))
    assert(not number(1.0) < number(.5))
    assert(not number(1.0) < number(.0))
    assert(not number(1.0) < number(-.5))

    assert(number(1.0) <= number(1.0))
    assert(not number(1.0) <= number(.5))
    assert(not number(1.0) <= number(.0))
    assert(not number(1.0) <= number(-.5))

    -- rhs 1

    assert(not number(1.0) > number(1.0) )
    assert(not number(.5) > number(1.0) )
    assert(not number(.0) > number(1.0) )
    assert(not number(-.5) > number(1.0) )

    assert(number(1.0) >= number(1.0) )
    assert(not number(.5) >= number(1.0) )
    assert(not number(.0) >= number(1.0) )
    assert(not number(-.5) >= number(1.0) )

    assert(not number(1.0) < number(1.0) )
    assert(number(.5) < number(1.0) )
    assert(number(.0) < number(1.0) )
    assert(number(-.5) < number(1.0) )

    assert(number(1.0) <= number(1.0) )
    assert(number(.5) <= number(1.0) )
    assert(number(.0) <= number(1.0) )
    assert(number(-.5) <= number(1.0) )

end

--assert(number_greater_than_or_equal(number(1), number(0)))

--- Array of functions, called at the very end after all else is defined
local final_setups = {}

--Creates an atlas for cards to use
SMODS.Atlas {
    key = "Airtokers",
    path = "Airtokers.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'penis_joker',
    loc_txt = {
        name = "Penis Joker!",
        text = {
            "{C:attention}+1 Penis{}",
        },
    },
    config = {},
    loc_vars = function()
        
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = 2,
                message = 'penis!',
            }
        end
    end
}

Airtokers.optional_features = {cardareas = {deck = true}}
SMODS.optional_features.cardareas.deck = true
SMODS.optional_features.cardareas.decks = true

SMODS.Joker {
    key = 'tomorrow_joker',
    loc_txt = {
        name = "Tomorrow Joker",
        text = {
            "The top {C:attention}#1#{} cards of your deck are scored",
        },
    },
    config = { extra = { topdeck_cards_scored = 4 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.topdeck_cards_scored } }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 4,
}

-- does not work at all with saving
SMODS.Joker {
    key = 'hungry_joker',
    loc_txt = {
        name = "Hungry Joker",
        text = {
            "When blind is selected, {C:attention}swallows{}",
            "{C:attention}#1#{} card from your deck.",
            "When sold, returns all {C:attention}swallowed{}",
            "cards to hand (or to deck)."
        },
    },
    config = { extra = { swallowed_cards = 1 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.swallowed_cards } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    -- swallows 1 card from your deck when blind is selected. when sold, returns all swallowed cards back to your deck 
    cost = 3,
    calculate = function(self, card, context)
        local shrunken_scale = 0.2
        local inverse_shrunken_scale = 1 / shrunken_scale
        if context.ending_shop then
            local swallowed_card = pseudorandom_element(G.deck.cards, pseudoseed('hungry'))
            if card.swallowed == nil then
                card.swallowed = CardArea(0, 0, 0, 0, {card_limit = 500, type = 'deck'})
                -- perhaps incorporate the offset and scale into the final design of the card. leave a hole in the art?
                card.swallowed:set_alignment({major = card, bond = 'Strong', type = 'bm', offset = {x = 0, y = 0.1} })
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'ease',
                ease = 'elastic',
                blockable = false,
                ref_table = swallowed_card.T,
                ref_value = 'h',
                ease_to = swallowed_card.T.h * shrunken_scale,
                delay =  0.4,
                func = (function(t) return t end)
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'ease',
                ease = 'elastic',
                blockable = false,
                ref_table = swallowed_card.T,
                ref_value = 'w',
                ease_to = swallowed_card.T.w * shrunken_scale,
                delay =  0.4,
                func = (function(t) return t end)
            }))
            draw_card(G.deck, card.swallowed, 50, 'down', false, swallowed_card)
            return {
                
            }
        end
        if context.selling_self then
            local spill_cards_into = #G.hand.cards > 0 and G.hand or G.deck
            for i, swallowed_card in ipairs(card.swallowed.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'h',
                    ease_to = swallowed_card.T.h * inverse_shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'w',
                    ease_to = swallowed_card.T.w * inverse_shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                draw_card(card.swallowed, spill_cards_into, 50, 'down', false, swallowed_card)
            end
            return true
        end
    end
}

local function count_played_cards()
    local tally = 0
    if not G.playing_cards then
        return 0
    end
    for k, v in pairs(G.playing_cards) do
        if v.base.times_played > 0 then tally = tally+1 end
    end
    return tally
end

SMODS.Joker {
    key = 'census',
    loc_txt = {
        name = "Census",
        text = {
            "Gives {C:red}+#1#{} Mult if every card",
            "in your deck has been played",
            "{C:inactive}(#2#/#3# cards in deck played){}",
        },
    },
    config = { extra = { mult = number(30) }},
    loc_vars = function(self, info_queue, card)
        debug.debug()
        return { vars = {
            card.ability.extra.mult,
            count_played_cards(),
            G.playing_cards and #G.playing_cards or 0,
            count_played_cards() >= (G.playing_cards and #G.playing_cards or 0),
        } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 6,
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.extra.mult = self.config.extra.mult:clone()
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if count_played_cards() >= #G.playing_cards then
                print('to_big', to_big)
                print('type(card.ability.extra.mult)', type(card.ability.extra.mult))
                return {
                    mult_mod = card.ability.extra.mult,
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'ender_joker',
    loc_txt = {
        name = "Ender Joker",
        text = {
            "Gives {C:red}#3##1#{} Mult",
            "Loses {C:red}#2#{} Mult each",
            "time you read this",
        },
    },
    config = { extra = { mult = number(17), mult_gain = number(-3) * 1 }},
    loc_vars = function(self, info_queue, card)
        print('hahaha you read it!')
        print(card.ability.extra.mult)
        print(card.ability.extra.mult_gain)
        print(card.ability.extra.mult_gain.array)
        print(card.ability.extra.mult_gain.sign)
        print(tprint(card.ability.extra.mult_gain.array))
        --print(tprint(card.ability.extra.mult_gain.sign))
        print(getmetatable(card.ability.extra.mult_gain))
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
        return { vars = {
            card.ability.extra.mult,
            card.ability.extra.mult_gain * -1,
            number_greater_than_or_equal(card.ability.extra.mult, number(0)) and "+" or "",
        } }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = number_greater_than_or_equal(card.ability.extra.mult, number(0)) and 'a_mult' or 'a_mult_minus', vars = { math.abs(card.ability.extra.mult) } }
            }
        end
    end
}

--- @schema
--- core: function(amount: number) -> nil,
--- mult?: boolean,  # remember, it's mult = mod_mult(x)
--- chips?: boolean,  # remember, it's hand_chips = mod_chips(x)
--- misc?: boolean,
--- text_function?: function,   # supercedes translation key
--- stylized_text?: boolean,    # requires translation key, applies text styling to card eval status text
--- translation_key?: string,
--- colour: table | function(amt: number) -> table,
--- sound?: string,
--- volume?: number,
--- amt?: number,
--- ['config.type']?: string,
--- ['config.scale']?: number,
Airtokers.custom_effects = {}

function Airtokers.check_custom_effects(effect, card, percent, mod_percent)
    for custom_effect_name, custom_effect in pairs(SMODS.Mods['Airtokers'].custom_effects) do
        if effect[custom_effect_name] then
            if effects[ii].card then juice_card(effects[ii].card) end
            custom_effect.core(effect[custom_effect_name])
            if not custom_effect.mult and not custom_effect.chips then custom_effect.misc = true end
            local hand_text_that_needs_updating = {}
            if custom_effect.mult then hand_text_that_needs_updating.mult = mult end
            if custom_effect.chips then hand_text_that_needs_updating.chips = hand_chips end
            update_hand_text({delay = 0}, hand_text_that_needs_updating)
            card_eval_status_text(card, custom_effect_name, effect[custom_effect_name], percent)
            mod_percent = true
        end
    end
    return mod_percent
end

function Airtokers.joker_check_custom_effects(effect, extras)
    for custom_effect_name, custom_effect in pairs(SMODS.Mods['Airtokers'].custom_effects) do
        if effect[custom_effect_name] then custom_effect.core(effect[custom_effect_name])
            if not custom_effect.mult and not custom_effect.chips then custom_effect.misc = true end
            if custom_effect.mult then extras.mult = true end
            if custom_effect.chips then extras.hand_chips = true end
            if custom_effect.misc then extras.misc = true end
        end
    end
end

local found_matching_status_text_effect = nil -- terrible but fuck it
local found_matching_status_amount = nil

function Airtokers.does_match_any_custom_effect_for_card_eval_status_text(card, eval_type, amt, percent, dir, extra)
    local is_match = Airtokers.custom_effects[eval_type] -- individual and held
    if is_match then 
        found_matching_status_text_effect = eval_type
        found_matching_status_amount = nil
        return true
    end
    for custom_effect_name, custom_effect in pairs(SMODS.Mods['Airtokers'].custom_effects) do -- joker or joker on joker
        if extra[custom_effect_name] then
            found_matching_status_text_effect = custom_effect_name
            found_matching_status_amount = extra[custom_effect_name]
            return custom_effect_name
        end
    end
    return false
end

function Airtokers.apply_custom_effects_to_card_eval_status_text(card, eval_type, amt, percent, dir, extra)
    local custom_effect = Airtokers.custom_effects[found_matching_status_text_effect]
    amt = found_matching_status_amount or amt
    found_matching_status_text_effect = nil -- consume it so it cannot be reused on accident!
    found_matching_status_amount = nil
    local text = custom_effect.text_function and custom_effect.text_function(amt) or localize{type='variable',key=custom_effect.translation_key or '',vars={amt}}
    if custom_effect.stylized_text then
        text = function(root_node, args) -- this function is args.text!!
            localize{type='variable_attention_text', key=custom_effect.translation_key, vars={amt}, nodes = root_node.nodes, scale = args.scale, maxw = args.maxw, colour = args.colour}
        end
    end
    return {
        sound = custom_effect.sound or 'generic1',
        volume = custom_effect.volume or 0.7,
        amt = custom_effect.amt or amt,
        text = text,
        colour = (type(custom_effect.colour) == 'table' and custom_effect.colour) or (type(custom_effect.colour) == 'function' and custom_effect.colour(amt)) or G.C.XMULT,
        ['config.type'] = custom_effect['config.type'] or 'fade',
        ['config.scale'] = custom_effect['config.scale'] or 1,
    }
end


Airtokers.custom_effects.log_mult = {
    core = function(amount)
        local result = nil
        if is_big(amount) or is_big(mult) then
            if number(mult).logBase then
                result = number(mult):logBase(number(amount))
            else
                result = number(mult):log(number(amount))
            end
        else
            print(inspect(amount))
            print(inspect(mult))
            print(is_big(amount))
            print(is_big(mult))
            print((amount.array and amount.sign) and true or false)
            print((mult.array and mult.sign) and true or false)
            assert(type(amount) ~= 'table')
            assert(type(mult) ~= 'table')
            result = math.log(mult, amount)
        end
        mult = mod_mult(result)
    end,
    mult = true,
    chips = false,
    stylized_text = true,
    translation_key = 'a_log_mult',
    colour = G.C.XMULT,
    sound = 'multhit2',
    volume = 0.7,
    amt = nil,
    ['config.scale'] = 0.7,
}

local function fill_dollar_buffer(amount)
    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + amount
    G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
end

Airtokers.custom_effects.toum_dollars = { -- reimplementation because Joker effects don't have immediate dollars
    core = function(amount)
        fill_dollar_buffer(amount)
        ease_dollars(amount)
    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function(text_amt) return (number_less_than(number(text_amt), number(-0.01)) and '-' or '')..localize("$")..tostring(math.abs(text_amt)) end,
    colour = function(colour_amt) return number_less_than(number(colour_amt), number(-0.01)) and G.C.RED or G.C.MONEY end,
    sound = 'coin3',
    volume = 1,
    amt = nil,
}

SMODS.Joker {
    key = 'log_joker',
    loc_txt = {
        name = "Log{y:20,E:3}2{} Joker",
        text = {
            "Applies {C:red}log{C:red,y:20,E:3}#1#{} Mult",
            "On the {C:attention}final hand{} of round,",
            "Jokers to the left",
            "each give {C:money}$#2#{}",
            "for every Joker to the",
            "left of this card",
            "{C:inactive}(Currently {C:money}$#3#{C:inactive} each)"
            -- "each give {C:money}$#2# for every {C:money}#3# you have",
            -- "{C:inactive}(Max of {C:money}$#4#{C:inactive} each)",
        },
    },
    config = { extra = { 
        log_mult = number(2),
        dollars = number(5),
        -- for_every_dollars = 4,
    }},
    loc_vars = function(self, info_queue, card)
        local my_pos = 1
        for i = 1, #(G and G.jokers and G.jokers.cards or {}) do
            if G.jokers.cards[i] == card then my_pos = i; break end
        end
        return { vars = {
            card.ability.extra.log_mult,
            card.ability.extra.dollars,
            card.ability.extra.dollars * number(my_pos - 1),
        } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.other_joker and G.GAME.current_round.hands_left == 0 then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            local their_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == context.other_joker and context.other_joker.area == G.jokers then their_pos = i; break end
            end
            if their_pos and my_pos and their_pos < my_pos then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    focus = context.other_joker,
                    toum_dollars = card.ability.extra.dollars * number(my_pos - 1),
                    --exp_mult = 2,
                }
            end
        end
        if context.joker_main then
            return {
                log_mult = card.ability.extra.log_mult,
                card = card,
            }
        end
    end
}

Airtokers.custom_effects.exp_mult = {
    core = function(amount)
        mult = mod_mult(amount ^ mult) -- amount is *base*. mult ^ amount should be called "power_mult"
    end,
    mult = true,
    chips = false,
    translation_key = 'a_exp_mult',
    colour = G.C.XMULT,
    sound = 'multhit2',
    volume = 0.7,
    amt = nil,
    ['config.scale'] = 0.7,
}

function Airtokers.log(x, base)
    --print('Airtokers.log', type(x), x, type(base), base)
    if type(x) == 'table' then return x:log(base) end
    local status, retval = pcall(function() return math.log(x, base) end)
    if not status then
        error('math.log was unhappy')
    end
    return retval
end

local function infinite_power_tower(x, depth)
    depth = depth or 20
    if depth == 0 then return x end
    return x ^ infinite_power_tower(x, depth - 1)
end
  
local function infinite_log_dungeon(x, depth)
    --print('type(depth)', type(depth), 'depth', depth)
    depth = depth or 20
    if depth == 0 then return x * number(1000000.4) end
    local logarand = infinite_log_dungeon(x, depth - 1)
    return Airtokers.log(number(logarand), number(x))
end

local function exp_mult_disclaimer(amount_raw)
    local amount = number(amount_raw)
    print(inspect(amount), inspect(number(0)))
    print('amount', amount.m, amount.e)
    print('0', number(0).m, number(0).e)
    print('amount', tprint(amount.array or {}), amount.sign)
    print('0', tprint(number(0).array or {}), number(0).sign)
    print('amount', amount.array[1], amount.sign)
    print('0', number(0).array[1], number(0).sign)
    print('number_greater_than', number_greater_than(amount, number(0)))
    print('number_greater_than_or_equal', number_greater_than_or_equal(amount, number(0)))
    if number_greater_than(amount, number(math.exp(math.exp(-1)))) then
        return { '(Always increases mult)', '', '', '', '', always=true }
    elseif number_greater_than(amount, number(1)) then
        local low_intersection = infinite_power_tower(amount)
        local high_intersection = infinite_log_dungeon(amount)
        return { '(Will decrease mult if between ', low_intersection, ' and ', high_intersection, ')' }
    elseif number_greater_than_or_equal(amount, number(0)) then -- greater than OR EQUAL may have been causing the problems
        local low_intersection = infinite_power_tower(amount)
        return { '(Will decrease mult if above ', low_intersection, ')', '', '' }
    end
    return { '(Is not defined for values that are not expressible as a fraction with an odd denominator)', '', '', '', '', undefined=true }
end

SMODS.Joker {
    key = 'exp_joker',
    loc_txt = {
        name = "Exp Joker",
        text = {
            "Applies {C:red}#22##1##23#^{} Mult if",
            "scored hand has:",
            "{C:attention}#2#{}#3#{V:1}#4#{}#5#{C:attention}#6#{}",
            "{C:attention}#7#{}#8#{V:2}#9#{}#10#{C:attention}#11#{}",
            "{C:attention}#12#{}#13#{V:3}#14#{}#15#{C:attention}#16#{}",
            "in that order.",
            "{s:0.8,C:inactive}(Changes each round)",
            "{s:0.8,C:inactive,O:24}#17#{s:0.8,C:red}#18#{s:0.8,C:inactive}#19#{s:0.8,C:red}#20#{s:0.8,C:inactive}#21#",
        },
    },
    -- yes_pool_flag = 'disabled_for_now',
    config = { extra = { exp_mult = number(2), }},
    loc_vars = function(self, info_queue, card)
        -- card.ability.extra.exp_mult = card.ability.extra.exp_mult - 0.1
        local vars = {
            card.ability.extra.exp_mult,
        }
            -- 9 of Spades that is a Glass Card
            -- King that is a Suitless Card
            -- Club that is a Rankless Card
            -- Stone Card
        for i, requirement in ipairs(self.trigger_requirements) do
            local suit = requirement.suit and SMODS.Suits[requirement.suit]
            local rank = requirement.rank and SMODS.Ranks[requirement.rank]
            local enhancement = requirement.enhancement and G.P_CENTERS[requirement.enhancement]
            table.insert(vars, rank and localize(rank.key, 'ranks') or '')
            table.insert(vars, rank and suit and localize{type='variable',key='exp_joker_rank_of_suit_infix'} or '')
            table.insert(vars, suit and localize(suit.key, rank and 'suits_plural' or 'suits_singular') or '')
            table.insert(vars, (rank or suit) and localize{type='variable',key='exp_joker_enhancement_qualifier'} or '')
            table.insert(vars, localize{type = 'name_text', set = 'Enhanced', key = enhancement.key})
            vars.colours = vars.colours or {}
            table.insert(vars.colours, suit and G.C.SUITS[suit.key] or G.C.SUITS.Spades)
            info_queue[#info_queue+1] = enhancement
        end
        local disclaimer_table = exp_mult_disclaimer(card.ability.extra.exp_mult)
        for i = 1, 5 do
            table.insert(vars, disclaimer_table[i])
        end
        table.insert(vars, number_less_than(number(card.ability.extra.exp_mult), number(0)) and '(' or '') -- #22#
        table.insert(vars, number_less_than(number(card.ability.extra.exp_mult), number(0)) and ')' or '') -- #23#
        table.insert(vars, disclaimer_table.always) -- 24, used to Omit disclaimer
        return { vars = vars }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    pick_trigger_requirements = function(self)
        self.trigger_requirements = {}
        for i = 1, 3 do
            local suit = pseudorandom_element(SMODS.Suits, pseudoseed('exp_joker'))
            local rank = pseudorandom_element(SMODS.Ranks, pseudoseed('exp_joker'))
            local enhancement = pseudorandom_element(G.P_CENTER_POOLS["Enhanced"], pseudoseed('exp_joker'))
            local requirement = { 
                suit = suit.key,
                rank = rank.key,
                enhancement = enhancement.key,
            }
            if enhancement.no_suit or enhancement.key == 'm_stone' then requirement.suit = nil end
            if enhancement.no_rank or enhancement.key == 'm_stone' then requirement.rank = nil end
            if enhancement.overrides_base_rank then rank = nil end
            table.insert(self.trigger_requirements, requirement)
        end
    end,
    set_ability = function(self, card, initial, delay_sprites)
        if not self.trigger_requirements then
            self:pick_trigger_requirements()
        end
        card.ability.trigger_requirements_saved = self.trigger_requirements
    end,
    load = function(self, card, card_table, other_card)
        if not self.trigger_requirements then
            self.trigger_requirements = card_table.ability.trigger_requirements_saved
            print('loaded requirements', tprint(self.trigger_requirements))
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers then
            self:pick_trigger_requirements()
            return {
                message = localize('k_reset')
            }
        end
        if context.joker_main then
            local index_of_next_requirement = 1
            for i, card in ipairs(context.scoring_hand) do
                local requirement = self.trigger_requirements[index_of_next_requirement]
                local suit = requirement.suit and SMODS.Suits[requirement.suit]
                local rank = requirement.rank and SMODS.Ranks[requirement.rank]
                local enhancement = requirement.enhancement and G.P_CENTERS[requirement.enhancement]
                local matches_requirement = true
                print('rank.id', rank.id, 'card:get_id()', card:get_id())
                print('suit.key', suit.key, 'card.base.suit', card.base.suit, 'card:is_suit(suit.key)', card:is_suit(suit.key))
                print('enhancement.key', enhancement.key, 'card.config.center.key', card.config.center.key)
                if rank and rank.id ~= card:get_id() then matches_requirement = false end
                if suit and not card:is_suit(suit.key) then matches_requirement = false end
                if enhancement and not SMODS.has_enhancement(card, enhancement.key) then matches_requirement = false end
                if matches_requirement then index_of_next_requirement = index_of_next_requirement + 1 end
            end
            print('exp_joker: index_of_next_requirement', index_of_next_requirement)
            if index_of_next_requirement > #self.trigger_requirements then
                return {
                    exp_mult = card.ability.extra.exp_mult,
                    card = card,
                }
            end
        end
    end
}

local original_smods_calculate_individual_effect = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    if Airtokers.custom_effects[key] then
        local custom_effect = Airtokers.custom_effects[key]
        custom_effect.core(effect[key])
        if not custom_effect.mult and not custom_effect.chips then custom_effect.misc = true end
        local hand_text_that_needs_updating = {}
        if custom_effect.mult then hand_text_that_needs_updating.mult = mult end
        if custom_effect.chips then hand_text_that_needs_updating.chips = hand_chips end
        update_hand_text({delay = 0}, hand_text_that_needs_updating)
        card_eval_status_text(scored_card, key, effect[key], percent)
        return true
    else
        return original_smods_calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    end
end

table.insert(final_setups, function()
    for custom_effect_name, custom_effect in pairs(Airtokers.custom_effects) do
        table.insert(SMODS.calculation_keys, custom_effect_name)
    end
end)

-- emplace card context
local original_cardarea_emplace = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped, a4, a5, a6, a7, a8, a9) -- any extra arguments another mod might add
    local return_value = original_cardarea_emplace(self, card, location, stay_flipped, a4, a5, a6, a7, a8, a9)
    if G and G.jokers and G.jokers.cards and G.hand and G.hand.cards then
        SMODS.calculate_context({emplace_card = true, card = card, area = self})
    end
    return return_value
end

-- flip card context
local original_card_flip = Card.flip
function Card:flip(a1, a2, a3, a4, a5, a6, a7, a8, a9) -- any extra arguments another mod might add
    local return_value = original_card_flip(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if G and G.jokers and G.jokers.cards and G.hand and G.hand.cards then
        SMODS.calculate_context({flip_card = true, card = self})
    end
    return return_value
end

G.FUNCS.DT_lose_game = G.FUNCS.DT_lose_game or function() if G.STAGE == G.STAGES.RUN then G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false end end

SMODS.Joker {
    key = 'reaper',
    loc_txt = {
        name = "Reaper",
        text = {
            "{X:mult,C:white} X#1# {} Mult",
            "{X:black,C:white} Game#3#Over {} if you see {C:tarot,T:c_death}#2#",
        },
    },
    config = { extra = { mult = number(4), arrived = false }},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS['c_death']
        return { vars = {
            card.ability.extra.mult,
            localize{type = 'name_text', key = 'c_death', set = 'Tarot'},
            ' ', -- empty string for X style
        } }
    end,
    rarity = 3,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 7,
    arrive = function(card, death_card)
        local prior_gamespeed = G.SETTINGS.GAMESPEED
        card.ability.extra.arrived = true
        return {
            func = function()
                G.E_MANAGER:add_event(Event({
                    func = (function(t)
                        prior_gamespeed = G.SETTINGS.GAMESPEED
                        G.SETTINGS.GAMESPEED = 0.5
                        return true
                    end),
                }))
            end,
            extra = {
                focus = death_card,
                message = 'Death',
                colour = G.C.BLACK,
                extra = {
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = (function(t)
                                G.SETTINGS.GAMESPEED = prior_gamespeed
                                print(G.GAME.chips)
                                print(G.GAME.blind.chips)
                                SMODS.saved = false
                                SMODS.calculate_context({ game_over = true })
                                if SMODS.saved then
                                    death_card.reaper_ward = true
                                    card.ability.extra.arrived = false
                                    return true
                                end
                                G.GAME.blind.config.blind = G.P_BLINDS['bl_toum_reaper_blind']
                                G.FUNCS.DT_lose_game()
                                return true
                            end),
                        }))
                    end
                },
            },
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.I.CARDAREA) do
            if v.cards then
                for i, vv in ipairs(v.cards) do
                    if vv.ability and vv.ability.name == 'Death' and vv.facing == 'front' and not card.ability.extra.arrived and not vv.reaper_ward then
                        G.E_MANAGER:add_event(Event({
                            func = (function(t)
                                -- don't trigger while paused when added to deck, not as funny as looking at death in collection
                                if G.SETTINGS.paused then return false end
                                SMODS.calculate_context({see_death = true, card = vv})
                                return true
                            end),
                        }))
                        
                    end
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if (context.emplace_card or context.flip_card or context.see_death) and context.card then
            if context.card.ability and context.card.ability.name == 'Death' and context.card.facing == 'front' and not card.ability.extra.arrived and not context.card.reaper_ward then
                return self.arrive(card, context.card)
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.mult,
            }
        end
    end
}

SMODS.Atlas{
    key = "ReaperBlind",
    path = "ReaperBlind.png",
    px = 34,
    py = 34,
    atlas_table = 'ANIMATION_ATLAS',
    frames = 21,
}

SMODS.Blind{
    key = 'reaper_blind',
    no_collection = true, -- this is just for the GAME OVER screen
    loc_txt = {
        name = "Reaper",
        text = {
            "{X:mult,C:white} X#1# {} Mult",
            "{C:tarot,T:c_death}#2# has arrived",
        },
    },
    atlas = 'ReaperBlind',
    mult = number(10) ^ (number(10) ^ (number(10) ^ number(10))),
    dollars = 1,
    boss_colour = G.C.BLACK,
    vars = {
        number(4),
        localize{type = 'name_text', key = 'c_death', set = 'Tarot'},
    },
    in_pool = function(self)
        return false
    end
}

local function shallow_copy_table(O)
    local O_type = type(O)
    local copy
    if O_type == 'table' then
        copy = {}
        for k, v in next, O, nil do
            copy[k] = v
        end
        setmetatable(copy, copy_table(getmetatable(O)))
    else
        copy = O
    end
    return copy
  end

-- Mr. Bones hack
local original_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context, a2, a3, a4, a5, a6, a7, a8, a9) -- any extra arguments another mod might add
    local recusion_depth = 0
    local return_value = original_calculate_joker(self, context, a2, a3, a4, a5, a6, a7, a8, a9)
    if not return_value and self.ability.name == 'Mr. Bones' and not context.end_of_round then
        local context_copy = shallow_copy_table(context)
        context_copy.end_of_round = true
        return_value = original_calculate_joker(self, context_copy, a2, a3, a4, a5, a6, a7, a8, a9)
    end
    return return_value
end

SMODS.Joker {
    key = 'scrapbook',
    loc_txt = {
        name = "Scrapbook",
        text = {
            "Gets another random effect",
            "when you purchase a {C:attention}Voucher",
            "when played hand is #1#, gives:" -- two pair
        },
    },
    config = {
        extra = {
            effect_choices = {
                { effect_type = 'xmult', amount = 1.5, },
                { effect_type = 'mult', amount = 4, },
                { effect_type = 'chips', amount = 40, },
            },
            effect_list = {

            }
        },
    },
    loc_vars = function()
        
    end,
    add_effect = function(card)
        local added_effect = pseudorandom_element(card.ability.extra.effect_choices, pseudoseed('scrapbook'))
        table.insert(card.ability.extra.effect_list, added_effect)
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    set_ability = function(self, card, initial, delay_sprites)
        G.E_MANAGER:add_event(Event({
            func = (function(t)
                self.add_effect(card)
                return true
            end),
        }))
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == 'Voucher' then
            self.add_effect(card)
        end
        if context.joker_main and (next(context.poker_hands['Two Pair']) or next(context.poker_hands['Full House'])) then
            local next_effect = {}
            local total_effect = next_effect
            for i, effect in ipairs(card.ability.extra_effect_list) do
                next_effect.extra = {}
                next_effect = next_effect.extra
                next_effect[effect.effect_type] = effect.amount
            end
            -- the top-level object does not contain any effects (besides extra)
            if total_effect.extra then
                return total_effect.extra
            end
        end
    end
}

function Airtokers.cos(x)
  if type(x) == 'table' then
    if getmetatable(x) == BigMeta then return math.cos(x:to_number()) end
    if getmetatable(x) == OmegaMeta then return math.cos(x:to_number()) end
  end
  return math.cos(x)
end


SMODS.Joker {
    key = 'spin_to_win',
    loc_txt = {
        name = "Spin to Win",
        text = {
            "This card spins",
            "Gives {X:mult,C:white} X#1# {} Mult",
            "Also gives {X:mult,C:white} XMult {} equal to",
            "the cosine of its angle",
            "when {C:attention}hand is played",
            "{E:3,C:inactive}(Currently {X:mult,C:white,E:3,D:3} this text gets discarded #2# {C:inactive,E:3} Mult)",
            "{s:0.8,C:inactive}(Spinning speed changes each hand)",
            "{s:0.8,C:inactive}(More cards scored causes faster spinning)",
        },
    },
    --[[
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        -- generate_card_ui(card.config.center, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
        ---[[
        local _c = card.config.center
        if not card then
            local ability = copy_table(cfg)
            ability.set = 'Joker'
            ability.name = _c.name
            local ret = {Card.generate_UIBox_ability_table({ ability = ability, config = { center = _c }, bypass_lock = true}, true)}
            specific_vars = ret[1]
            if ret[2] then desc_nodes[#desc_nodes+1] = ret[2] end
            --main_end = ret[3]
        end
        if specific_vars and specific_vars.pinned then info_queue[#info_queue+1] = {key = 'pinned_left', set = 'Other'} end
        if specific_vars and specific_vars.sticker then info_queue[#info_queue+1] = {key = string.lower(specific_vars.sticker)..'_sticker', set = 'Other'} end
        localize{type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = specific_vars or {}}
        --] ]
        full_UI_table.name = localize{type = 'name', set = _c.set, key = _c.key, nodes = full_UI_table.name}
        --[[
        if not ((specific_vars and not specific_vars.sticker) and (card_type == 'Default' or card_type == 'Enhanced')) then
            if desc_nodes == full_UI_table.main and not full_UI_table.name then
                localize{type = 'name', key = _c.key, set = _c.set, nodes = full_UI_table.name} 
                if not full_UI_table.name then full_UI_table.name = {} end
            elseif desc_nodes ~= full_UI_table.main and not desc_nodes.name then
                desc_nodes.name = localize{type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set} 
            end
        end
        --] ]
    
        desc_nodes[#desc_nodes+1] = {
            {n=G.UIT.T, config={text = '  +',colour = G.C.MULT, scale = 0.32}},
            {n=G.UIT.O, config={object = DynaText({string = {{ ref_table = card.ability.extra, ref_value = 'cos_angle_string' }}, colours = {G.C.RED},pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0})}},
        }
    end,
    --]]


    config = {
        extra = { 
            xmult = number(2),
            spin_speed = 2 / 40, --number(2 / 40),
            spin_speed_min = 2 /40 ,--number(2 / 40), 
            spin_speed_max = 12/ 40,--number(12 / 40),
            cos_angle = 0,
            cos_angle_string = '0',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.xmult,
            Airtokers.cos(card.angle),
            { ref_table = card.ability.extra, ref_value = 'cos_angle_string' },
        } }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    set_ability = function(self, card, initial, delay_sprites)
        G.E_MANAGER:add_event(Event({
            func = (function(t)
                card.do_not_align_rotation = true
                card.ability.extra.spin_speed = card.ability.extra.spin_speed_min + pseudorandom('me_pleading_with_oin_to_let_me_out_of_the_washing_machine') * (card.ability.extra.spin_speed_max - card.ability.extra.spin_speed_min)
                return true
            end),
        }))
    end,
    update = function(self, card, dt)
        card.angle = card.angle or 0
        if card.area and card.area.config.collection then
            dt = card.previous_time and G.TIMERS['REAL'] - card.previous_time or 0
            card.previous_time = G.TIMERS['REAL']
        else
            dt = dt / G.SETTINGS.GAMESPEED
        end
        dt = dt * 4 -- my settings have changed my expectations
        card.angle = card.angle + dt * card.ability.extra.spin_speed
        card.angle = card.angle % (6968 * math.pi) -- causes a brief stutter, so keep it infrequent
        card.T.r = primitive_number(card.angle)
        assert(type(card.T.r) ~= 'table')
        card.ability.extra.cos_angle = identity(Airtokers.cos(card.angle))
        local rounded_angle = card.ability.extra.cos_angle + identity(0) -- copy if its a table
        if math.abs(rounded_angle) < identity(0.01) then rounded_angle = identity(0) end
        card.ability.extra.cos_angle_string = 'X'..format_ui_value(rounded_angle)
        --card.states.drag.is = true
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.spin_speed = 0
            local speed_multiplier = context.scoring_hand and #context.scoring_hand or 1
            speed_multiplier = identity(speed_multiplier) ^ identity(1.4) -- extra kick for more cards :)
            
            local rounded_angle = card.ability.extra.cos_angle + identity(0) -- copy if its a table
            if math.abs(rounded_angle) < identity(0.01) then rounded_angle = identity(0) end
            return {
                xmult = card.ability.extra.xmult,
                extra = {
                    xmult = Airtokers.cos(card.angle),
                    extra = {
                        func = (function(t)
                            G.E_MANAGER:add_event(Event({ 
                                func = function() 
                                    card.ability.extra.spin_speed = speed_multiplier * (card.ability.extra.spin_speed_min + pseudorandom('me_pleading_with_oin_to_let_me_out_of_the_washing_machine') * (card.ability.extra.spin_speed_max - card.ability.extra.spin_speed_min))
                                    return true
                                end,
                            }))
                        end),
                    }
                },
            }
        end
    end
}


Airtokers.custom_effects.digit_reverse_chips = {
    core = function(amount)
        local chips_string = tostring(hand_chips)
        local digit_groups = {}
        for digit_group in string.gfind(chips_string, '%d+') do
            digit_groups[digit_group] = true
        end
        for digit_group, v in pairs(digit_groups) do
            local reversed_digit_group = string.reverse(digit_group)
            digit_groups[digit_group] = reversed_digit_group
            chips_string = string.gsub(chips_string, digit_group, reversed_digit_group, 1)
        end
        local chips_number = number(chips_string)
        hand_chips = mod_chips(chips_number)
    end,
    mult = false,
    chips = true,
    translation_key = 'a_digit_reverse_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.digit_invert_chips = {
    core = function(amount)
        local chips_string = tostring(hand_chips)
        local digit_groups = {}
        for digit_group in string.gfind(chips_string, '%d+') do
            digit_groups[digit_group] = true
        end
        for digit_group, v in pairs(digit_groups) do
            local inverted_digit_group = ''
            for i = 1, #digit_group do
                local c = string.sub(digit_group, i,i)
                local inverted_c = 9 - tonumber(c)
                inverted_digit_group = inverted_digit_group .. tostring(inverted_c)
            end
            digit_groups[digit_group] = inverted_digit_group
            chips_string = string.gsub(chips_string, digit_group, inverted_digit_group, 1)
        end
        local chips_number = number(chips_string)
        hand_chips = mod_chips(chips_number)
    end,
    mult = false,
    chips = true,
    translation_key = 'a_digit_invert_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.negate_chips = {
    core = function(amount)
        hand_chips = mod_chips(-hand_chips)
    end,
    mult = false,
    chips = true,
    translation_key = 'a_negate_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}


local function factorial_continued_fraction_step_a(x, i, max_depth)
    i = i or 0
    max_depth = max_depth or 35
    if i >= max_depth then return x end
    return number(2) + number(2 * i) - x + number(i + 1) * ( (x - number(i + 1)) / factorial_continued_fraction_step_a(x, i+1))
end
local function factorial_continued_fraction_step_b(x, i, max_depth)
    i = i or 0
    max_depth = max_depth or 35
    if i >= max_depth then return x end
    return x + number(2 * i) - ( (x - number(i)) / (x + number(2 * i + 1) + (number(i+1)/factorial_continued_fraction_step_b(x, i+1)) ) )
end
local sqrt_2pi = (number(2) * number(math.pi)) ^ number(0.5)
local nan = 0/0 -- omegun prints nan as Infinity but it is still nan under the hood
local function factorial(x)
    if number_equal(x, number(0)) then
        --print('base case 0', x)
        return number(1)
    end
    if number_equal(x, number(-1)) then
        --print('base case -1', x)
        return number(nan) 
    end
    if number_greater_than(x, number(-1)) and number_less_than(x, number(150)) and ((type(x) == 'number' and math.floor(x) == x) or (type(x) == 'table' and (x.isint and x:isint()) or (x.floor and number_equal(x:floor(), x))) or number_equal(x % number(1), number(0))) then
        --print('definition', x)
        -- for integers, use definition
        local acc = number(1)
        local i = x
        while number_greater_than(i, number(1)) do
            acc = acc * i
            i = i - number(1)
        end
        return (acc)
    elseif number_less_than(x, number(9)) and number_greater_than(x, number(-1)) then
        --print('continued fraction', x)
        -- continued fraction approximation for real values near 0
        -- gamma function shift
        local x_plus_one = x + number(1)
        local new_chips = (number(math.exp(-1)) / factorial_continued_fraction_step_a(x_plus_one, 0, 35)) + (number(math.exp(-1)) / factorial_continued_fraction_step_b(x_plus_one, 0, 35))
        return (new_chips)
    elseif is_positive(x) then
        --print("stirling's approximation", x)
        -- stirling's approximation
        local new_chips = sqrt_2pi * ((x / number(math.exp(1))) ^ x) * (number(1) + (number(1) / (number(12) * x)) + (number(1) / (number(288) * (x ^ 2))) - (number(139) / (number(51840) * (x ^ 3))) )
        return (new_chips)
    elseif number_greater_than(x, number(-40)) then
        --print('recursive definition', x)
        -- recursive definition
        local x_plus_one_factorial = factorial((x + number(1)))
        if x_plus_one_factorial ~= x_plus_one_factorial or (type(x_plus_one_factorial) == 'table' and x_plus_one_factorial.isNaN and x_plus_one_factorial:isNaN()) then
            return number(nan)
        end
        return (number(1) / (x + number(1))) * x_plus_one_factorial
    else
        --print('base case very negative', x)
        return number(nan) -- likely an asymptote
    end
end
Airtokers.custom_effects.factorial_chips = {
    core = function(amount)
        hand_chips = mod_chips(factorial(hand_chips))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_factorial_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}

-- factorial chips test
--[[
for i = -100, 200 do 
    local i_over_10 = i/10
    print(tostring(i_over_10)..'!', factorial(number(i_over_10)))
end
--]]

Airtokers.custom_effects.rad_2_deg_chips = {
    core = function(amount)
        hand_chips = mod_chips(hand_chips * number(180 / math.pi))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_rad_2_deg_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.deg_2_rad_chips = {
    core = function(amount)
        hand_chips = mod_chips(hand_chips * number(math.pi / 180))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_deg_2_rad_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.abs_chips = {
    core = function(amount)
        if is_positive(hand_chips) then
            hand_chips = mod_chips(hand_chips)
        else
            hand_chips = mod_chips(hand_chips * number(-1))
        end
    end,
    mult = false,
    chips = true,
    translation_key = 'a_abs_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.succ_chips = {
    core = function(amount)
        hand_chips = mod_chips(hand_chips + number(1))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_succ_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.sign_chips = {
    core = function(amount)
        if is_zero(hand_chips) then
            hand_chips = mod_chips(number(0))
        elseif is_positive(hand_chips) then
            hand_chips = mod_chips(number(1))
        else
            hand_chips = mod_chips(number(-1))
        end
    end,
    mult = false,
    chips = true,
    translation_key = 'a_sign_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.increase_digits_chips = {
    core = function(amount)
        local chips_string = tostring(hand_chips)
        chips_string = string.gsub(chips_string, '9', '<special token>')
        chips_string = string.gsub(chips_string, '8', '9')
        chips_string = string.gsub(chips_string, '7', '8')
        chips_string = string.gsub(chips_string, '6', '7')
        chips_string = string.gsub(chips_string, '5', '6')
        chips_string = string.gsub(chips_string, '4', '5')
        chips_string = string.gsub(chips_string, '3', '4')
        chips_string = string.gsub(chips_string, '2', '3')
        chips_string = string.gsub(chips_string, '1', '2')
        chips_string = string.gsub(chips_string, '0', '1')
        chips_string = string.gsub(chips_string, '<special token>', '10') -- hmm
        local chips_number = number(chips_string)
        hand_chips = mod_chips(chips_number)
    end,
    mult = false,
    chips = true,
    translation_key = 'a_digit_increase_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}


local prime_limit = 1000000
local primes_up_to_1000000_spaced = {}
sendInfoMessage('Calculating primes less than 1000000, started at '..os.date('%H:%M:%S'), "Mod-Airtokers-Prime-Calculation")
for i = 2, math.sqrt(prime_limit) do
    if primes_up_to_1000000_spaced[i] == nil then 
        for j = i, prime_limit, i do
            primes_up_to_1000000_spaced[j] = false
        end
        primes_up_to_1000000_spaced[i] = true
    end
end
local primes_up_to_1000000 = {}
for i = 2, prime_limit do
    if primes_up_to_1000000_spaced[i] ~= false then -- true or nil
        table.insert(primes_up_to_1000000, i)
    end
end
primes_up_to_1000000_spaced = nil
sendInfoMessage('Calculating primes less than 1000000, found '..tostring(#primes_up_to_1000000)..', should have found 78,498, finished at '..os.date('%H:%M:%S'), "Mod-Airtokers-Prime-Calculation")

local function is_prime(n)
    if number_greater_than(n, number(100000 ^ 2)) then
        return false
    end
    local limit = (n ^ 0.5)
    local i = number(2)
    while number_less_than(i, limit) do
        if (n % number(i)) then 
            return false
        end
        i = i + number(1)
    end
    return true
end

local function eulers_totient_function(n)
    n = number_round_towards_positive_infinity(n)
    local original_n = n
    local original_sign = number(1)
    if is_negative(n) then
        original_sign = number(-1)
    end
    n = math.abs(n)
    if (number_greater_than(n, number(100000000))) then
        return original_n * number(6 / (math.PI ^ 2))
    end
    local prime_factorization =  {}
    local prime_index = 1
    local last_prime_index = #primes_up_to_1000000
    while number_greater_than(n, number(1)) and prime_index <= last_prime_index do
        while number_equal(n % number(primes_up_to_1000000[prime_index]), number(0)) do
            n = n / number(primes_up_to_1000000[prime_index])
            prime_factorization[primes_up_to_1000000[prime_index]] = (prime_factorization[primes_up_to_1000000[prime_index]] or 0) + 1
        end
        prime_index = prime_index + 1
    end
    if number_greater_than(n, number(1)) then
        if is_prime(n) then
            prime_factorization[n] = 1
        else
            return original_n * number(6 / (math.PI ^ 2))
        end
    end
    local product = number(1)
    for p, m in pairs(prime_factorization) do
        product = product * ((number(p) ^ number(m)) - (number(p) ^ (number(m) - number(1))))
    end
    return product * original_sign
end

Airtokers.custom_effects.eulers_totient_function_chips = {
    core = function(amount)
        hand_chips = mod_chips(eulers_totient_function(hand_chips))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_eulers_totient_function_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.7,
}

-- 6000
assert(number_equal(eulers_totient_function(number(5*5*5*2*2*2*2*3)), number(1600)))
print(eulers_totient_function(number(-27)))


SMODS.Joker {
    key = 'test_joker',
    loc_txt = {
        name = "Test Joker",
        text = {
            --"{C:chips}Digit reverses{} chips",
            "Applies {C:chips}Euler's totient function{} to chips",
        },
    },
    config = {},
    loc_vars = function()
        
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                --digit_reverse_chips = 1,
                --digit_invert_chips = 1,
                eulers_totient_function_chips = 1,
            }
        end
    end
}

table.insert(final_setups, function ()
    for k, v in pairs(Airtokers.custom_effects) do
        print('Airtokers has '.. k)
    end
end)


--- 1 extra hand of cards is drawn when opening booster packs
SMODS.Joker{
    key = 'card_rack',
    loc_txt = {
        name = "Card Rack",
        text = {
            "Draw an {C:attention}extra{} hand of cards",
            "when opening a {C:attention}Booster Pack",
        },
    },
    config = {},
    loc_vars = function()
        
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.open_booster then
            G.E_MANAGER:add_event(Event({
                func = function(t)
                    G.E_MANAGER:add_event(Event({
                        func = function(t)
                            G.E_MANAGER:add_event(Event({
                                func = function(t)
                                    local message = localize { type = 'variable', key = 'k_plus_cards', vars = { G.hand.config.card_limit } }
                                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = message })
                                    local num_cards_already_in_hand = math.max(#G.hand.cards, 1)
                                    print(num_cards_already_in_hand)
                                    for i = 1, G.hand.config.card_limit do 
                                        draw_card(G.deck,G.hand, (num_cards_already_in_hand + i)*100/num_cards_already_in_hand,'up', true)
                                    end
                                    return true
                                end
                            }))
                            return true
                        end
                    }))
                    return true
                end
            }))
            return {
                -- something happened!
            }
        end
    end    
}

Airtokers.custom_effects.distance_mult = {
    core = function(amount)
        mult = mod_mult(number_abs(mult - number(amount)))
    end,
    mult = true,
    chips = false,
    translation_key = 'a_distance_mult',
    colour = G.C.MULT,
    sound = 'multhit1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

-- draw card context
local original_draw_card = draw_card
function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only, a12, a13, a14, a15, a16) -- any extra arguments another mod might add
    local return_value = original_draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only, a12, a13, a14, a15, a16) -- normally returns nil but whatever
    if G and G.jokers and G.jokers.cards and G.hand and G.hand.cards then
        SMODS.calculate_context({draw_card = true, card = card, from = from, to = to})
    end
    return return_value
end

--- applies distance to 6 to mult. distance target increases by 4 whenever drawing a card that is exactly 10 ranks away from the previously drawn card.
SMODS.Joker{
    key = 'boundary_stone',
    loc_txt = {
        name = "Boundary Stone",
        text = {
            "Applies {C:mult}Distance to #1#{} to Mult",
            "Gains {C:mult}#2# Distance{} when drawn card is exactly",
            "ten ranks away from previously drawn card",
        },
    },
    config = { 
        extra = {
            distance_mult = number(6),
            distance_mult_gain = number(1),
            previous_drawn_rank = nil,
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.distance_mult,
            velocitize(card.ability.extra.distance_mult_gain),
        } }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                distance_mult = card.ability.extra.distance_mult,
            }
        end
        if context.emplace_card and context.area == G.hand then
            local matched = false
            local current_drawn_rank = context.card:get_id()
            if (
                card.ability.extra.previous_drawn_rank and
                current_drawn_rank and
                type(card.ability.extra.previous_drawn_rank) == 'number' and
                type(current_drawn_rank) == 'number' and
                (
                    math.abs(card.ability.extra.previous_drawn_rank - current_drawn_rank) == 10 or 
                    (card.ability.extra.previous_drawn_rank == 14 and current_drawn_rank == 11) or
                    (card.ability.extra.previous_drawn_rank == 11 and current_drawn_rank == 14)
                )
            ) then
                matched = true
            end
            print(card.ability.extra.previous_drawn_rank)
            card.ability.extra.previous_drawn_rank = context.card:get_id()
            if matched then
                card.ability.extra.distance_mult = card.ability.extra.distance_mult + card.ability.extra.distance_mult_gain
                card:juice_up(0.5, 0.5)
                return {
                    focus = context.card,
                    message = localize { type = 'variable', key = 'k_plus_distance', vars = { card.ability.extra.distance_mult_gain } },
                    colour = G.C.MULT,
                    front_of_event_queue = true,
                }
            end
        end
    end    
}

SMODS.Sound {
    key = 'elevatorcrash1',
    path = 'SuperCrash.wav',
}
SMODS.Sound {
    key = 'elevatorcable1',
    path = 'elevator_cable1.ogg',
}
SMODS.Sound {
    key = 'elevatorcable2',
    path = 'elevator_cable2.ogg',
}
SMODS.Sound {
    key = 'ploop1',
    path = 'ploop1.ogg',
}
SMODS.Sound {
    key = 'ploop2',
    path = 'ploop2.ogg',
}
SMODS.Sound {
    key = 'ploop3',
    path = 'ploop5.ogg',
}
SMODS.Sound {
    key = 'ploop4',
    path = 'ploop4.ogg',
}
SMODS.Sound {
    key = 'ploop5',
    path = 'ploop5.ogg',
}

local original_cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    local previous_states_drag_is = {}
    for k, card in ipairs(self.cards) do
        if card.do_not_align_to_cardarea then 
            previous_states_drag_is[card] = card.states.drag.is
            card.states.drag.is = true
        end
    end 
    local return_value = original_cardarea_align_cards(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    for k, card in ipairs(self.cards) do
        if card.do_not_align_to_cardarea then 
            card.states.drag.is = previous_states_drag_is[card]
        end
    end 
    return return_value
end

function Card:elevator_crash()
    G.E_MANAGER:add_event(Event({
        func = function(t)
            self.do_not_align_to_cardarea = true
            return true
        end,
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        ease = 'lerp',
        blocking = false,
        ref_table = { dummy = 0 },
        ref_value = 'dummy',
        ease_to = 1,
        delay = 1.8,
        func = function(t)
            if math.random() + (t/10) > 0.8 then
                play_sound('toum_elevatorcable'..math.random(2), 1 + t + (math.random() * 0.3), 1.5)
            end
            return t
        end,
    }))
    local fall_distance = 14
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        ease = 'quad_reverse',
        blockable = false,
        ref_table = self.T,
        ref_value = 'y',
        ease_to = self.T.y + fall_distance,
        delay =  1.4,
        func = (function(t) return t end)
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        ease = 'quad_reverse',
        blockable = false,
        ref_table = self.VT,
        ref_value = 'y',
        ease_to = self.VT.y + fall_distance,
        delay =  1.4,
        func = (function(t) return t end)
    }))
    if G.GAME.blind.name == 'The Water' then
        delay(0.3)
    end
    G.E_MANAGER:add_event(Event({
        func = function(t)
            if G.GAME.blind.name == 'The Water' then
                play_sound('toum_ploop'..math.random(5), 1, 5)
            else
                G.ROOM.jiggle = G.ROOM.jiggle + 67
                play_sound('toum_elevatorcrash1')
            end
            return true
        end,
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 1.4,
        func = (function() 
            self:remove() 
            return true 
        end)
    }))
end

--- Gives +mult equal to the difference between point value on played cards (K, Q, J, 10 all share a floor)
SMODS.Joker{
    key = 'elevator',
    loc_txt = {
        name = "Elevator",
        text = {
            "Each scored card gives {C:mult}+Mult",
            "equal to how different its {C:chips}Chips{} value is",
            "from the previous scored card",
            "{s:0.8,C:inactive,O:1}(Needs a consumable slot for installation)",
        },
    },
    config = {
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.added_to_deck,
        } }
    end,
    rarity = 3,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    cost = 8,
    custom_check_for_buy_space = function(self, card, is_negative)
        if not (#G.jokers.cards < G.jokers.config.card_limit + (is_negative and 1 or 0)) then
            alert_no_space(card, G.jokers)
            return false
        end
        if not (#G.consumeables.cards < G.consumeables.config.card_limit + (is_negative and 1 or 0)) then
            alert_no_space(card, G.consumeables)
            return false
        end
        return true
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            play_sound('timpani')
            local counterweight = create_card('elevator_part', G.consumeables, nil, nil, nil, nil, 'c_toum_counterweight', 'elevator')
            if card.edition then
                counterweight:set_edition(card.edition)
            end
            counterweight:add_to_deck()
            G.consumeables:emplace(counterweight)
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.scoring_hand then
            local other_card_index = nil
            for i, v in ipairs(context.scoring_hand) do
                if v == context.other_card then
                    other_card_index = i
                    break
                end
            end
            if not other_card_index then
                return nil
            end
            local prior_card = context.scoring_hand[other_card_index - 1]
            if not prior_card then
                return nil
            end
            -- very heavy bonus card, stone card, and hiker synergy
            local difference = number(prior_card:get_chip_bonus()) - number(context.other_card:get_chip_bonus())
            difference = math.abs(difference)
            if is_zero(difference) then
                return nil
            end
            return {
                mult = difference,
                card = card,
            }
        end
    end    
}
-- after some testing holy CRAP is this powerful. I don't have the heart to add a downside or nerf it so I made it Rare and expensive
-- after some more thought, yes it is powerful but it's not *that* powerful. I think I can keep it a rare and lower the price

--- this is the balance for Elevator. or rather, the counterbalance

SMODS.ConsumableType {
    key = 'elevator_part',
    primary_colour = G.C.GREY,
    secondary_colour = G.C.GREY,
    loc_txt = {
        name = 'Elevator Part',
        collection = 'Elevator Parts',
    },
    shop_rate = 0.0,
}

SMODS.Consumable {
    key = 'counterweight',
    set = 'elevator_part',
    loc_txt = {
        name = "Counterweight",
        text = {
            "Sell this to crash an Elevator",
        },
    },
    config = {
        consumeable = nil,
    },
    loc_vars = function()
    end,
    atlas = "Airtokers",
    pos = {x = 0, y = 0},
    add_to_deck = function(self, card, from_debuff)
        card.ability.useless_consumable = true
    end,
    load = function(self, card, card_table, other_card)
        card.ability.useless_consumable = true
    end,
    calculate = function(self, card, context)
        if context.selling_self then
            local _, first_elevator = next(SMODS.find_card('j_toum_elevator'))
            if not first_elevator then
                return nil
            end
            return {
                func = function()
                    first_elevator:elevator_crash()
                end,
            }
        end
    end

}


--- A random cycle of ranks is setup for this seed. Each played card will have its rank set to the next in the cycle.
--- Apply Rental to a random joker if played hand contains no Spades. Convert chips from radians to degrees if played hand contains no Spades.



--- final setups!

for _, func in ipairs(final_setups) do
    func()
end

----------------------------------------------
------------MOD CODE END----------------------
