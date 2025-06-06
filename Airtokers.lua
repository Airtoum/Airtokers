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
Airtokers.debug = {}

local function primitive_math_sign(n)
    return (n < 0 and -1) or 1
end

local function number(n)
    if Airtokers.is_big(n) then
        return n
    end
    if to_big and Big then
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
    return tonumber(n)
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

local function is_talisman_bignumber(x)
    return (type(x) == 'table') and (x.e and x.m)
end

local function are_both_big(a, b)
    return is_big(a) and is_big(b)
end

local function is_one_big(a, b)
    return is_big(a) or is_big(b)
end

local function number_equal(a, b)
    if are_both_big(a,b) then
        return a:eq(b)
    end
    if is_one_big(a,b) then
        return number(a):eq(number(b))
    end
    return a == b
end
Airtokers.number_equal = number_equal

assert(number_equal(number(1600), number(1600)))

local function is_zero(a)
    return number_equal(a, number(0))
end
Airtokers.is_zero = is_zero

local function is_positive(a)
    if is_big(a) and a.is_positive then
        return not is_zero(a) and a:is_positive()
    end
    return number(a) > number(0)
end
Airtokers.is_positive = is_positive

local function is_negative(a)
    if is_big(a) and a.is_negative then
        return a:is_negative()
    end
    return number(a) < number(0)
end
Airtokers.is_negative = is_negative

local function number_not_equal(a, b)
    if are_both_big(a,b) then
        return not a:eq(b)
    end
    if is_one_big(a,b) then
        return not number(a):eq(number(b))
    end
    return a ~= b
end
Airtokers.number_not_equal = number_not_equal

local function number_greater_than(a, b)
    if are_both_big(a,b) then
        return a:gt(b)
    end
    if is_one_big(a,b) then
        return number(a):gt(number(b))
    end
    return a > b
end
Airtokers.number_greater_than = number_greater_than

local function number_less_than(a, b)
    if are_both_big(a,b) then
        return a:lt(b)
    end
    if is_one_big(a,b) then
        return number(a):lt(number(b))
    end
    return a < b
end
Airtokers.number_less_than = number_less_than

-- bignum favors the number with the higher exponent, and ranges 0-1 have negative exponents, where 0 has exponent of 0. We must handle 0 specifically
local function number_greater_than_or_equal(a, b)
    --if number_equal(a, b) then return true end
    if are_both_big(a,b) then
    --    if is_zero(a) then return is_negative(b) end
    --    if is_zero(b) then return is_positive(a) end
        return a:gte(b)
    end
    if is_one_big(a,b) then
        return number(a):gte(number(b))
    end
    return a >= b
end

local function number_less_than_or_equal(a, b)
    --if number_equal(a, b) then return true end
    if are_both_big(a,b) then
    --    if is_zero(a) then return is_negative(b) end
    --    if is_zero(b) then return is_positive(a) end
        return a:lte(b)
    end
    if is_one_big(a,b) then
        return number(a):gte(number(b))
    end
    return a <= b
end

-- don't worry! this is not a ceiling function!
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

-- bignum does not implement this correctly, it copies the omeganum implementation without any changes
local function number_mod(a, b)
    if is_talisman_bignumber(a) and is_talisman_bignumber(b) then
        return a:sub(a:div(b):floor():mul(b))
    end
    if is_talisman_bignumber(a) then
        return a:sub(a:div(number(b)):floor():mul(number(b)))
    end
    if is_talisman_bignumber(b) then
        return number(a):sub(number(a):div(b):floor():mul(b))
    end
    return a % b
end

if true then
    local result = number_mod(number(5040*6), number(7*7))
    local expected = number(7)
    result = result - 0.0001
    result = number_round_towards_positive_infinity(result)
    assert(number_equal(result, expected), tostring(result) .. ' did not equal '..tostring(expected) )

    assert(number_less_than(number_mod(number(120000), number(2)), number(2)))
    --assert(number_equal(number_mod(number(120000), number(2)), number(0)))
end

local function number_equal_with_tolerance(a, b, tolerance)
    return number_less_than(number_abs(a - b), tolerance)
end

local function num_to_str_full(n)
    if is_big(n) then
        return string.format("%18.18f", to_number(n))
    end
    return string.format("%18.18f", n)
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
    path = "AirtokersArt.png",
    px = 71,
    py = 95,
}

SMODS.Atlas {
    key = "CardRack",
    path = "CardRack.png",
    px = 71,
    py = 95,
}

SMODS.Atlas {
    key = "Menu",
    path = "Menu.png",
    px = 71,
    py = 113,
}

SMODS.Atlas {
    key = "SpinToWin",
    path = "Spin to Win.png",
    px = 71,
    py = 95,
}

SMODS.Atlas {
    key = "Counterweight",
    path = "Counterweight.png",
    px = 71,
    py = 95,
}

function create_UIBox_Penis()
    local scale = 0.4
    local spacing = 0.13
    local temp_col = G.C.DYN_UI.BOSS_MAIN
    local temp_col2 = G.C.DYN_UI.BOSS_DARK
    local def = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR }, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = 1.45 * 2, minh = 1 * 2, colour = temp_col, emboss = 0.05, r = 0.1}, nodes={
            {n=G.UIT.R, config={align = "cm", maxw = 1.35 * 2}, nodes={
                {n=G.UIT.T, config={text = localize('k_penis'), minh = 0.33 * 2, scale = 0.85*scale, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
            }},
            {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 1.2 * 2, colour = temp_col2, id = 'row_penis_text'}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME, ref_value = 'penis'}}, colours = {G.C.IMPORTANT},shadow = true, scale = 4*scale}),id = 'penis_UI_count'}},
            }},
        }},
    }}
    local row_round_UI = G.HUD:get_UIE_by_ID('row_round')
    G.HUD_penis = UIBox{
        definition = def,
        config = {major = row_round_UI, align = 'cm', offset = {x=2,y=-0.5}, bond = 'Weak'},
    }
    G.HUD_penis:set_role({
        role_type = 'Major',
    })
    G.HUD_penis.states.click.can = true
    G.HUD_penis.states.drag.can = true
    G.HUD_penis.T.x = G.GAME.penis_x or G.HUD_penis.T.x
    G.HUD_penis.T.y = G.GAME.penis_y or G.HUD_penis.T.y
    local original_penis_stop_drag = G.HUD_penis.stop_drag
    function G.HUD_penis.stop_drag(self)
        original_penis_stop_drag(self)
        G.GAME.penis_x = G.HUD_penis.T.x
        G.GAME.penis_y = G.HUD_penis.T.y
    end
end

table.insert(final_setups, function ()
    Airtokers['custom_effect'..'s'].penis = {
        core = function(amount)
            G.E_MANAGER:add_event(Event({
                func = function()
                    local penis_before = G.GAME.penis
                    G.GAME.penis = (G.GAME.penis or 0) + 1
                    if not penis_before then
                        create_UIBox_Penis()
                    end
                    G.HUD_penis:recalculate()
                    local penis_UI = G.HUD_penis:get_UIE_by_ID('penis_UI_count')
                    local col = ((amount < 0) and G.C.RED) or G.C.IMPORTANT
                    ---[[
                    attention_text({
                        text = velocitize(amount),
                        scale = 1.6, 
                        hold = 0.7,
                        cover = penis_UI.parent,
                        cover_colour = col,
                        align = 'cm',
                    })
                    --]]
                    return true
                end
            }))
        end,
        mult = false,
        chips = false,
        misc = true,
        translation_key = 'a_penis',
        colour = G.C.IMPORTANT,
        sound = 'multhit1',
        volume = 1,
        amt = nil,
        ['config.scale'] = 0.7,
    }
end)

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
                penis = 1,
            }
        end
    end
}

Airtokers.optional_features = {cardareas = {deck = true}}
SMODS.optional_features.cardareas.deck = true
SMODS.optional_features.cardareas.decks = true
SMODS.optional_features.retrigger_joker = true

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
    pos = {x = 1, y = 0},
    cost = 4,
}

-- saving hook
local original_card_save = Card.save
function Card:save(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if self.config and self.config.center and self.config.center.toum_on_save and type(self.config.center.toum_on_save) == 'function' then
        self.config.center:toum_on_save(self)
    end
    local return_value = original_card_save(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    return return_value
end

local original_g_uidef_view_deck = G.UIDEF.view_deck
function G.UIDEF.view_deck(unplayed_only, a2, a3, a4, a5, a6, a7, a8, a9)
    local unmodified_playing_cards = {}
    for i, card in ipairs(G.playing_cards) do
        unmodified_playing_cards[i] = card
    end
    local original_playing_cards = G.playing_cards
    local filtered_playing_cards = {}
    for i, card in ipairs(G.playing_cards) do
        if card and card.area and card.area.separate_container_for_playing_cards and not G.UIDEF.view_deck_param_actually_view_mini_deck then
           -- pass 
        else
            table.insert(filtered_playing_cards, card)
        end
    end
    G.playing_cards = filtered_playing_cards
    local return_value = original_g_uidef_view_deck(unplayed_only, a2, a3, a4, a5, a6, a7, a8, a9)
    G.playing_cards = original_playing_cards
    return return_value
end

--- this is fucking dumb
G.UIDEF.view_deck_param_actually_view_mini_deck = false
function G.UIDEF.view_mini_deck(mini_deck)
    local original_playing_cards = G.playing_cards
    local cards_in_deck_to_view = mini_deck.cards
    G.playing_cards = cards_in_deck_to_view
    G.UIDEF.view_deck_param_actually_view_mini_deck = true
    local return_value = G.UIDEF.view_deck(false)
    G.UIDEF.view_deck_param_actually_view_mini_deck = false
    G.playing_cards = original_playing_cards
    return return_value
end

function G.UIDEF.mini_deck_info(mini_deck)
    return create_UIBox_generic_options({contents ={create_tabs(
      {tabs = {
        {
          label = localize('b_full_deck'),
          chosen = true,
          tab_definition_function = G.UIDEF.view_mini_deck,
          tab_definition_function_args = mini_deck,
        },
      },
      tab_h = 8,
      snap_to_nav = true}
    )}})
end

G.FUNCS.mini_deck_info = function(e)
    G.SETTINGS.paused = true
    if G.deck_preview then 
      G.deck_preview:remove()
      G.deck_preview = nil
    end
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.mini_deck_info( e -- pass in deck?
      ),
    }
  end

local original_cardarea_click = CardArea.click
function CardArea:click(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    local return_value = original_cardarea_click(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if self.mini_deck then 
        G.FUNCS.mini_deck_info(self)
    end
    return return_value
end

function Airtokers.property_map(t, prop)
    local r = {}
    for k, v in pairs(t) do
        r[k] = v[prop] or 'nil'
    end
    return r
end

--[[
function prismo()
    local _, hungry_joker = next(SMODS.find_card('j_toum_hungry_joker'))
    local swallowed_card = hungry_joker.swallowed.cards[1]
    for k, v in ipairs(G.DRAW_HASH) do
        if v == hungry_joker then
            print(k..': hungry joker')
        end
        if v == swallowed_card then
            print(k..': swallowed card')
        end
        if v.is and v:is(UIBox) and v.parent and v.parent == G.jokers then
            print(k..': G.Jokers UIBox')
        end
    end
end
function pramso()
    local _, hungry_joker = next(SMODS.find_card('j_toum_hungry_joker'))
    local swallowed_card = hungry_joker.swallowed.cards[1]
    for k, v in ipairs(G.CONTROLLER.collision_list) do
        if v == hungry_joker then
            print(k..': hungry joker')
        end
        if v == swallowed_card then
            print(k..': swallowed card')
        end
        if v.is and v:is(UIBox) and v.parent and v.parent == G.jokers then
            print(k..': G.Jokers UIBox')
        end
    end
end
function jisma()
    local _, hungry_joker = next(SMODS.find_card('j_toum_hungry_joker'))
    local swallowed_card = hungry_joker.swallowed.cards[1]
    for k, v in ipairs(G.I.CARD) do
        if v == hungry_joker then
            print(k..': hungry joker')
        end
        if v == swallowed_card then
            print(k..': swallowed card')
        end
        if v.is and v:is(UIBox) and v.parent and v.parent == G.jokers then
            print(k..': G.Jokers UIBox')
        end
    end
end
--]]

local original_card_click = Card.click
function Card:click(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if self.config and self.config.center and self.config.center.toum_click and type(self.config.center.toum_click) == 'function' then
        local return_value = self.config.center:toum_click(self)
        if return_value then
            return return_value
        end
    end
    local return_value = original_card_click(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if self.area and self.area ~= G.deck and self.area.mini_deck and self.area.cards[1] == self then 
        G.FUNCS.mini_deck_info(self.area)
    end
    return return_value
end

local function index_of(list, element)
    for k, v in pairs(list) do
        if v == element then
            return k
        end
    end
    return nil
end

SMODS.DrawStep {
    key = 'early_center',
    order = -10000,
    func = function(self, layer)
        local center = self.config.center
        if center.early_draw and type(center.early_draw) == 'function' then
            center:early_draw(self, layer)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'draw_after_drawhash',
    order = 1013,
    func = function(self, layer)
        local center = self.config.center
        if center.draw_after_drawhash and type(center.draw_after_drawhash) == 'function' then
            center:draw_after_drawhash(self, layer)
        end
    end,
    conditions = { vortex = false },
}

local original_card_remove_from_deck = Card.remove_from_deck
function Card:remove_from_deck(from_debuff, a2, a3, a4, a5, a6, a7, a8, a9)
    local return_value = original_card_remove_from_deck(self, from_debuff, a2, a3, a4, a5, a6, a7, a8, a9)
    local obj = self.config.center
    if obj and obj.remove_from_deck_even_if_not_in_deck and type(obj.remove_from_deck_even_if_not_in_deck) == 'function' then
        obj:remove_from_deck_even_if_not_in_deck(self, from_debuff)
    end
    return return_value
end

-- needs special hook for saving
SMODS.Joker {
    shrunken_scale = 0.5,
    inverse_shrunken_scale = 1 / 0.5,
    swallowed_vertical_alignment = -0.1,
    key = 'hungry_joker',
    loc_txt = {
        name = "Hungry Joker",
        text = {
            "When exiting shop, {C:attention}swallows{}",
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
    pos = {x = 2, y = 0},
    -- swallows 1 card from your deck when blind is selected. when sold, returns all swallowed cards back to your deck 
    cost = 3,
    set_ability = function(self, card, initial, delay_sprites)
        card.swallowed = CardArea(0, 0, 0, 0, {card_limit = 500, type = 'deck'})
        -- perhaps incorporate the offset and scale into the final design of the card. leave a hole in the art?
        card.swallowed:set_alignment({major = card, bond = 'Strong', type = 'bm', offset = {x = 0, y = self.swallowed_vertical_alignment} })
        card.swallowed.separate_container_for_playing_cards = true
        card.swallowed.mini_deck = true
        -- render on bottom
        table.remove(G.I.CARDAREA, index_of(G.I.CARDAREA, card.swallowed))
        table.insert(G.I.CARDAREA, 1, card.swallowed)
        -- invisible click card, on top
        --card.invisible_click_card = Card(0,0,0,0,pseudorandom_element(G.P_CARDS, pseudoseed('hungry_i_guess')), G.P_CENTERS.c_base)
        --card.invisible_click_card:set_alignment({major = card, bond = 'Strong', type = 'bm', offset = {x = 0, y = self.swallowed_vertical_alignment} })
        --card.invisible_click_card.states.visible = false
        --card.invisible_click_card.T.h = card.invisible_click_card.T.h * self.shrunken_scale
        --card.invisible_click_card.T.w = card.invisible_click_card.T.w * self.shrunken_scale
    end,
    toum_on_save = function(self, card)
        card.ability.extra.swallowed = card.swallowed:save()
    end,
    load = function(self, card, card_table, other_card) -- i'm pretty sure other_card is vestigial
        card.swallowed = CardArea(0, 0, 0, 0, {card_limit = 500, type = 'deck'})
        card.swallowed:set_alignment({major = card, bond = 'Strong', type = 'bm', offset = {x = 0, y = self.swallowed_vertical_alignment} })
        card.swallowed.separate_container_for_playing_cards = true
        card.swallowed.mini_deck = true
        card.swallowed:load(card_table.ability.extra.swallowed)
        for i, v in ipairs(card.swallowed.cards) do
            v.T.h = v.T.h * self.shrunken_scale
            v.T.w = v.T.w * self.shrunken_scale
        end
        -- render on bottom
        table.remove(G.I.CARDAREA, index_of(G.I.CARDAREA, card.swallowed))
        table.insert(G.I.CARDAREA, 1, card.swallowed)
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            local cards_to_swallow = {}
            for i, card_to_swallow in ipairs(G.deck.cards) do
                if not card_to_swallow.swallowed_by_toum_hungry_joker then
                    table.insert(cards_to_swallow, card_to_swallow)
                    -- render on top
                    --table.remove(G.I.CARD, index_of(G.I.CARD, card))
                    --table.insert(G.I.CARD, card)
                end
            end
            local swallowed_anything = false
            for i = 1, card.ability.extra.swallowed_cards do
                local swallowed_card = pseudorandom_element(cards_to_swallow, pseudoseed('hungry'))
                -- local swallowed_card = G.deck.cards[1]
                if card.swallowed == nil then
                    error('Hungry Joker did not have a CardArea')
                end
                if not swallowed_card then
                    break
                end
                swallowed_anything = true
                swallowed_card.swallowed_by_toum_hungry_joker = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'h',
                    ease_to = swallowed_card.T.h * self.shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'w',
                    ease_to = swallowed_card.T.w * self.shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                draw_card(G.deck, card.swallowed, 50, 'down', false, swallowed_card)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        swallowed_card.swallowed_by_toum_hungry_joker = nil
                        return true
                    end,
                }))
            end
            return swallowed_anything and {} or nil
        end
        if context.selling_self and not context.blueprint then
            local spill_cards_into = #G.hand.cards > 0 and G.hand or G.deck
            for i, swallowed_card in ipairs(card.swallowed.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blocking = false,
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'h',
                    ease_to = swallowed_card.T.h * self.inverse_shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'ease',
                    ease = 'elastic',
                    blocking = false,
                    blockable = false,
                    ref_table = swallowed_card.T,
                    ref_value = 'w',
                    ease_to = swallowed_card.T.w * self.inverse_shrunken_scale,
                    delay =  0.4,
                    func = (function(t) return t end)
                }))
                draw_card(card.swallowed, spill_cards_into, 50, 'down', false, swallowed_card)
            end
            return {}
        end
    end,
    remove_from_deck_even_if_not_in_deck = function(self, card, from_debuff)
        if not from_debuff then
            for i, v in ipairs(card.swallowed) do
                v:start_dissolve()
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blockable = false,
                func = function()
                    card.swallowed:remove()
                    card.swallowed = nil
                    return true
                end,
                delay =  1.06*0.7,
            }))
        end
    end,
    --[[
    early_draw = function(self, card, layer)
        if card.swallowed == nil then
            error('Hungry Joker did not have a CardArea')
        end
        card.swallowed:draw(layer)
        for i, swallowed_card in ipairs(card.swallowed.cards) do
            swallowed_card.temporary_invisible = {{nil}}
            if not card.marked_as_early_draw then
                card.marked_as_early_draw = true
                print('hunry joker early draw')
            end
        end
    end,
    draw = function(self, card, layer)
        if not card.marked_as_draw then
            card.marked_as_draw = true
            print('hunry joker draw')
        end
    end
    ]]
    --[[
    toum_click = function(self, card)
        print('toum click')
        if index_of(G.CONTROLLER.collision_list, card.swallowed) or index_of(G.CONTROLLER.collision_list, card.swallowed.cards[1]) then
            print('toum click activate!!')
            card.swallowed:click()
            return true
        end
    end,
    --]]
    -- this makes the cards clickable like they're on top of hungry joker even if they render below hungry joker
    draw_after_drawhash = function(self, card, layer)
        for i, swallowed_card in ipairs(card.swallowed.cards) do
            local index_in_draw_hash = index_of(G.DRAW_HASH, swallowed_card)
            if index_in_draw_hash then
                table.remove(G.DRAW_HASH, index_in_draw_hash)
                add_to_drawhash(swallowed_card)
            end
        end
    end,
}

--SMODS.DrawSteps['center'].func = function() end

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
        return { vars = {
            card.ability.extra.mult,
            count_played_cards(),
            G.playing_cards and #G.playing_cards or 0,
            count_played_cards() >= (G.playing_cards and #G.playing_cards or 0),
        } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 3, y = 0},
    cost = 6,
    set_ability = function(self, card, initial, delay_sprites)
        --card.ability.extra.mult = self.config.extra.mult:clone()
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if count_played_cards() >= #G.playing_cards then
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
    config = { extra = { mult = number(17), mult_gain = number(-3) * 1, mult_min = number(-200), mult_max = number(200) }},
    loc_vars = function(self, info_queue, card)
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
        card.ability.extra.mult = math.max(card.ability.extra.mult, card.ability.extra.mult_min)
        card.ability.extra.mult = math.min(card.ability.extra.mult, card.ability.extra.mult_max)
        return { vars = {
            card.ability.extra.mult,
            card.ability.extra.mult_gain * -1,
            number_greater_than_or_equal(card.ability.extra.mult, number(0)) and "+" or "",
        } }
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 4, y = 0},
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
--- text_function?: function(amount: number) -> string,   # supercedes translation key
--- stylized_text?: boolean,    # requires translation key, applies text styling to card eval status text
--- translation_key?: string,
--- colour: table | function(amt: number) -> table,
--- sound?: string,
--- volume?: number,
--- amt?: number,
--- transform_amt?: function(amount: number) -> number
--- ['config.type']?: string,
--- ['config.scale']?: number,
--- playing_cards_created?: boolean  # triggers playing card joker context (eg hologram)
--- 
--- template:
--- Airtokers.custom_effects.new_effect = {
---     core = function(amount) end,
---     mult = false,
---     chips = false,
---     misc = true,
---     translation_key = 'a_new_effect',
---     colour = G.C.XMULT,
---     sound = 'generic1' or 'multhit1' or 'multhit2' or 'chips1' or 'coin3',
---     volume = 1 or 0.7,
---     ['config.scale'] = 0.7,
--- }
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

SMODS.Shader {
    key = 'logarithmic',
    path = 'logarithmic.fs',
}

SMODS.Joker {
    key = 'log_joker',
    loc_txt = {
        name = "Log{y:20,E:3}2{} Joker",
        text = {
            "Applies {C:red}log{C:red,y:20,E:3}#1#{} Mult",
            "On the {C:attention}final hand{} of round,",
            "Jokers to the left each give {C:money}$#2#{}",
            "for every Joker to the left",
            "of this card",
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
    pos = {x = 0, y = 1},
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
    end,
    draw = function(self, card, layer)
        local working_canvas = card.children.center.canvas
        love.graphics.setCanvas(working_canvas)
        love.graphics.clear(0,0,0,0)
        --card.children.center.canvas = nil -- lest it try to draw its canvas on itself! this lets it fallback to the atlas
        --card.children.center:draw_shader('toum_logarithmic', nil, 2.0)
        local moveable = card.children.center
        love.graphics.push()
        love.graphics.reset()
        love.graphics.setCanvas(working_canvas)
        --[[
        love.graphics.scale(G.TILESCALE*G.TILESIZE)
        love.graphics.translate(
            -moveable.VT.w/2,
            -moveable.VT.h/2
        )
        love.graphics.translate(
            -1*1*(1)/2,
            -1*1*(1)/2)
        --love.graphics.translate(-2, -2)
        --love.graphics.scale(card.children.center.VT.w, card.children.center.VT.h)
        print(card.children.center.VT.x, card.children.center.VT.y, card.children.center.VT.w, card.children.center.VT.h)
        love.graphics.scale(1/(card.children.center.scale.x/card.children.center.VT.w), 1/(card.children.center.scale.y/card.children.center.VT.h))
        local _draw_major = card.children.center.role.draw_major or card.children.center
        --]]
        love.graphics.scale(3)
        G.SHADERS['toum_logarithmic']:send("texture_details", card.children.center:get_pos_pixel())
        G.SHADERS['toum_logarithmic']:send("image_details",card.children.center:get_image_dims())
        G.SHADERS['toum_logarithmic']:send('screen_scale', 1)
        G.SHADERS['toum_logarithmic']:send('mouse_screen_pos', {0,0})
        G.SHADERS['toum_logarithmic']:send('hovering', 0)
        G.SHADERS['toum_logarithmic']:send("shadow", false)
        G.SHADERS['toum_logarithmic']:send("logarithmic", G.TIMERS.REAL * 0.03)
        love.graphics.setShader( G.SHADERS['toum_logarithmic'])
        --love.graphics.setShader()
        card.children.center:set_sprite_pos(card.children.center.sprite_pos)
        love.graphics.draw(
            card.children.center.atlas.image,
            card.children.center.sprite,
            0 ,0,
            0
        )
        --card.children.center.canvas = working_canvas
        love.graphics.pop()
        love.graphics.setCanvas(G.CANVAS)
        love.graphics.setShader()
    end,
    set_sprites = function(self, card, front)
        card.children.center.canvas = love.graphics.newCanvas(71* 3, 95 *3)
        --card.T.scale = card.T.scale * (1/3)
        --card.T.w = card.T.w * (1/3)
        --card.T.h = card.T.h * (1/3)
        --card.children.center.scale.x = card.children.center.scale.x * (1/3)
        --card.children.center.scale.y = card.children.center.scale.y * (1/3)
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
    if number_greater_than(amount, number(math.exp(math.exp(-1)))) then
        return { '(Always increases Mult)', '', '', '', '', always=true }
    elseif number_greater_than(amount, number(1)) then
        local low_intersection = infinite_power_tower(amount)
        local high_intersection = infinite_log_dungeon(amount)
        return { '(Will decrease Mult if between ', low_intersection, ' and ', high_intersection, ')' }
    elseif number_greater_than_or_equal(amount, number(0)) then -- greater than OR EQUAL may have been causing the problems
        local low_intersection = infinite_power_tower(amount)
        return { '(Will decrease Mult if above ', low_intersection, ')', '', '' }
    end
    return { '(Is not defined for values that are not expressible as a fraction with an odd denominator)', '', '', '', '', undefined=true }
end

SMODS.Joker {
    key = 'lightning_rod_oven',
    loc_txt = {
        name = "Lightning Rod Oven",
        text = {
            "Applies {C:red}#22##1##23#^{} Mult if scored hand has:",
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
    pos = {x = 1, y = 1},
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
        local amt = effect[key]
        if type(custom_effect.transform_amt) == 'function' then 
            amt = custom_effect.transform_amt(amt)
        end
        custom_effect.core(amt, {scored_card = scored_card})
        if not custom_effect.mult and not custom_effect.chips then custom_effect.misc = true end
        local hand_text_that_needs_updating = {}
        if custom_effect.mult then hand_text_that_needs_updating.mult = mult end
        if custom_effect.chips then hand_text_that_needs_updating.chips = hand_chips end
        update_hand_text({delay = 0}, hand_text_that_needs_updating)
        card_eval_status_text(scored_card, key, amt, percent, nil, custom_effect.playing_cards_created and {playing_cards_created = {true}} or nil)
        return true
    else
        return original_smods_calculate_individual_effect(effect, scored_card, key, amount, from_edition)
    end
end

table.insert(final_setups, function()
    local index_of_extra = nil
    for i, calc_key in ipairs(SMODS.calculation_keys) do
        if calc_key == 'extra' then
            index_of_extra = i
            break
        end
    end
    -- extra must happen after my custom effects.
    assert(index_of_extra, "Could not find calculation key 'extra' in SMODS.calculation_keys. :(")
    for custom_effect_name, custom_effect in pairs(Airtokers.custom_effects) do
        table.insert(SMODS.calculation_keys, index_of_extra, custom_effect_name)
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
    pos = {x = 2, y = 1},
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
                                    death_card.ability.reaper_ward = true
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
                    if vv.ability and vv.ability.name == 'Death' and vv.facing == 'front' and not card.ability.extra.arrived and not vv.ability.reaper_ward then
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
            if context.card.ability and context.card.ability.name == 'Death' and context.card.facing == 'front' and not card.ability.extra.arrived and not context.card.ability.reaper_ward then
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
  
local function remove_all_properties_of_type_recursively(t, type_to_remove)
    if type(t) ~= 'table' then 
        return t
    end
    for k, v in pairs(t) do
        if type(v) == type_to_remove then
            t[k] = nil
        end
        if type(v) == 'table' then
            remove_all_properties_of_type_recursively(v, type_to_remove)
        end
    end
    return t
end

local last_card_passed_to_card_eval_status_text = nil
local last_extra_passed_to_card_eval_status_text = nil

Airtokers.debug.last_card_passed_to_card_eval_status_text = function()
    return last_card_passed_to_card_eval_status_text
end
Airtokers.debug.last_extra_passed_to_card_eval_status_text = function()
    return last_extra_passed_to_card_eval_status_text
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
    --- for scrapbook
    if return_value or context.setting_blind or context.ending_shop or context.open_booster then
        local shallow_copy = shallow_copy_table(return_value)
        local pruned_copy = copy_table_but_not_these_classes(shallow_copy, {Object})
        if return_value == true or context.setting_blind or context.ending_shop or context.open_booster then
            if last_card_passed_to_card_eval_status_text == self and last_extra_passed_to_card_eval_status_text and last_extra_passed_to_card_eval_status_text.message then
                self.ability.toum_most_recent_trigger = { 
                    message = last_extra_passed_to_card_eval_status_text.message,
                    colour = last_extra_passed_to_card_eval_status_text.colour,
                }
            end
        else
            self.ability.toum_most_recent_trigger = remove_all_properties_of_type_recursively(pruned_copy, 'function')
        end
    end
    return return_value
end

function copy_table_but_not_these_classes(O, classes)
    seen = seen or {}
    local O_type = type(O)
    local copy
    if O_type == 'table' then
        if O.is then
            for i, class in ipairs(classes) do
                if O:is(class) then
                    print('found a thing! set nil for a ' .. tostring(class))
                    return nil
                end
            end
        end
        if getmetatable(O) ~= nil and getmetatable(O) == BigMeta then return Big:new(O) end
        if getmetatable(O) ~= nil and getmetatable(O) == OmegaMeta then
            return O:clone()
        end
        copy = {}
        for k, v in next, O, nil do
            local key = copy_table_but_not_these_classes(k, classes)
            if key then -- you cannot set the 'nil' property of a table
                copy[key] = copy_table_but_not_these_classes(v, classes)
            end
        end
        setmetatable(copy, copy_table(getmetatable(O)))
    else
        copy = O
    end
    return copy
end

local original_card_sell_card = Card.sell_card
function Card:sell_card(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    local return_value = original_card_sell_card(self, a1, a2, a3, a4, a5, a6, a7, a8, a9)
    G.GAME.toum_last_sold_last_triggered_effect = self.ability.toum_most_recent_trigger and
        remove_all_properties_of_type_recursively(copy_table_but_not_these_classes(self.ability.toum_most_recent_trigger, {Object}), 'function')
    return return_value
end

local original_card_eval_status_text = card_eval_status_text
function card_eval_status_text(card, eval_type, amt, percent, dir, extra, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
    last_card_passed_to_card_eval_status_text = card
    last_extra_passed_to_card_eval_status_text = extra
    if last_extra_passed_to_card_eval_status_text and last_extra_passed_to_card_eval_status_text.message then
        last_card_passed_to_card_eval_status_text.ability.toum_most_recent_trigger = last_card_passed_to_card_eval_status_text.ability.toum_most_recent_trigger or { 
            message = last_extra_passed_to_card_eval_status_text.message,
            colour = last_extra_passed_to_card_eval_status_text.colour,
        }
    end
    return original_card_eval_status_text(card, eval_type, amt, percent, dir, extra, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
end

local function build_card_making_custom_effect(card_type, psuedo_key_suffix, translation_key, colour, cardarea_key, buffer_key, rarity)
    return {
        core = function(amount)
            --cardarea_key is necessary since G.jokers is nil upon startup
            if not (#(G[cardarea_key].cards) + G.GAME[buffer_key] < G[cardarea_key].config.card_limit) then
                return
            end
            G.GAME[buffer_key] = G.GAME[buffer_key] + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                        local card = create_card(card_type, G[cardarea_key], nil, rarity, nil, nil, nil, psuedo_key_suffix)
                        card:add_to_deck()
                        G[cardarea_key]:emplace(card)
                        G.GAME[buffer_key] = 0
                    return true
                end)}))
        end,
        mult = false,
        chips = false,
        misc = true,
        text_function = function()
            return localize(translation_key)
        end,
        colour = colour,
        sound = 'generic1',
        volume = 1 or 0.7,
        transform_amt = function(amt)
            if not (#(G[cardarea_key].cards) + G.GAME[buffer_key] < G[cardarea_key].config.card_limit) then
                return 0
            end
            return amt
        end,
        ['config.scale'] = 0.7,
    }
end

Airtokers.custom_effects.toum_plus_tarot = build_card_making_custom_effect('Tarot', '8ba', 'k_plus_tarot', G.C.IMPORTANT, 'consumeables', 'consumeable_buffer', nil) -- meant to be G.C.SECONDARY_SET.Tarot in vanilla but it's not set correctly
Airtokers.custom_effects.toum_plus_spectral = build_card_making_custom_effect('Spectral', 'sixth', 'k_plus_spectral', G.C.SECONDARY_SET.Spectral, 'consumeables', 'consumeable_buffer', nil)
Airtokers.custom_effects.toum_plus_joker = build_card_making_custom_effect('Joker', 'rif', 'k_plus_joker', G.C.BLUE, 'jokers', 'joker_buffer', 0)

--- views are subclasses of instances!! that's wild
function CardArea:DrawFromBack()
    self.__index = self
    local wrapper = self:extend()
    function wrapper.remove_card(wrapperself, card, discarded_only, a3, a4, a5, a6, a7, a8, a9)
        local original_config_type = self.config.type
        self.config.type = ((self.config.type == 'discard' or self.config.type == 'deck') and 'play') or 'deck'
        local return_value = self:remove_card(card, discarded_only, a3, a4, a5, a6, a7, a8, a9)
        self.config.type = original_config_type
        return return_value
    end
    return wrapper
end

Airtokers.custom_effects.toum_plus_stone = {
    core = function(amount, params)
        G.E_MANAGER:add_event(Event({
            func = function() 
                local front = pseudorandom_element(G.P_CARDS, pseudoseed('marb_fr'))
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, front, G.P_CENTERS.m_stone, {playing_card = G.playing_card})
                card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                G.play:emplace(card)
                table.insert(G.playing_cards, card)
                return true
            end}))
        card_eval_status_text(params.scored_card, 'extra', nil, nil, nil, {message = localize('k_plus_stone'), colour = G.C.SECONDARY_SET.Enhanced})

        G.E_MANAGER:add_event(Event({
            func = function() 
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                return true
            end}))

        draw_card(G.play:DrawFromBack(),G.deck, 90,'up', nil)  


        playing_card_joker_effects({true})
    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function()
            return ''
        end,
    colour = G.C.XMULT,
    amt = 0,
    sound = 'generic1' or 'multhit1' or 'multhit2' or 'chips1' or 'coin3',
    volume = 1 or 0.7,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.toum_plus_hands = {
    core = function(amount)
        ease_hands_played(amount)
    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function(amount)
        return localize{type = 'variable', key = 'a_hands', vars = {amount}}
    end,
    colour = G.C.IMPORTANT,
    sound = 'generic1',
    volume = 1 or 0.7,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.toum_boss_disabled = {
    core = function(amount, params)
        G.E_MANAGER:add_event(Event({func = function()
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.blind:disable()
                play_sound('timpani')
                delay(0.4)
                return true end }))
            card_eval_status_text(params.scored_card, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled')})
        return true end }))
    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function(amount)
        return ''
    end,
    amt = 0,
    colour = G.C.IMPORTANT,
    sound = 'generic1',
    volume = 1 or 0.7,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.toum_perkolate = {
    core = function(amount, params)
        if G.consumeables.cards[1] then
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local card = copy_card(pseudorandom_element(G.consumeables.cards, pseudoseed('perkeo')), nil)
                    card:set_edition({negative = true}, true)
                    card:add_to_deck()
                    G.consumeables:emplace(card) 
                    return true
                end}))
            card_eval_status_text(params.scored_card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
        end
    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function(amount)
        return ''
    end,
    amt = 0,
    colour = G.C.IMPORTANT,
    sound = 'generic1',
    volume = 1 or 0.7,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.toum_first_played_copied = {
    core = function(amount, params)
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = copy_card(G.play.cards[1], nil, nil, G.playing_card)
        _card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, _card)
        G.hand:emplace(_card)
        _card.states.visible = nil

        G.E_MANAGER:add_event(Event({
            func = function()
                _card:start_materialize()
                return true
            end
        }))

        --card_eval_status_text(params.scored_card, 'extra', nil, nil, nil, {message = localize('k_copied_ex'), colour = G.C.IMPORTANT})

    end,
    mult = false,
    chips = false,
    misc = true,
    text_function = function(amount)
        return localize('k_copied_ex')
    end,
    colour = G.C.CHIPS,
    sound = 'generic1',
    volume = 1 or 0.7,
    ['config.scale'] = 0.7,
    playing_cards_created = true,
}

-- don't feel like it right now
--Airtokers.custom_effects.toum_midas_gold

local function append_effect_to_tower(tower, effect)
    for i=1,600 do
        if tower.extra == nil then
            tower.extra = effect
            return
        end
        if type(tower.extra) ~= 'table' then
            error('extra is not a table, aaah!')
        end
        tower = tower.extra
    end
end

-- source: https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

local function matches_localized(text, key)
    if type(text) ~= 'string' then
        return false
    end
    local pattern = string.gsub(escape_pattern(localize{type = 'variable', key = key, vars = {'SpecialReplacementToken'}}), 'SpecialReplacementToken', '(.+)')
    local match = string.match(text, pattern)
    return match and number(match)
end

-- english-specific tests
--assert(matches_localized('+1 Hands', 'a_hands'))
--assert(not matches_localized('+1 Jokers', 'a_hands'))


SMODS.Joker {
    key = 'scrapbook',
    loc_txt = {
        name = "Scrapbook",
        text = {
            "Gives the effect that the most recently",
            "{C:attention}sold{} card gave when it was last triggered",
        },
    },
    config = {
        extra = {
            remembered_effect = nil
        }
    },
    loc_vars = function()
        
    end,
    rarity = 1,
    atlas = "Airtokers",
    pos = {x = 3, y = 1},
    cost = 2,
    augment_effect = function(self, card, effect)
        if not effect then return end
        local amount = nil
        if effect.message == localize('k_plus_tarot') or effect.extra and effect.extra.message == localize('k_plus_tarot') then
            append_effect_to_tower(effect, { toum_plus_tarot = 1 })
            if effect.message == localize('k_plus_tarot') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_plus_tarot') then effect.extra.message = nil end
        end
        if effect.message == localize('k_again_ex') or effect.extra and effect.extra.message == localize('k_again_ex') then
            effect.toum_scrapbook_retrigger_self = true
            if effect.message == localize('k_again_ex') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_again_ex') then effect.extra.message = nil end
        end
        if effect.message == localize('k_plus_spectral') or effect.extra and effect.extra.message == localize('k_plus_spectral') then
            append_effect_to_tower(effect, { toum_plus_spectral = 1 })
            if effect.message == localize('k_plus_spectral') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_plus_spectral') then effect.extra.message = nil end
        end
        if effect.message == localize('k_plus_stone') or effect.extra and effect.extra.message == localize('k_plus_stone') then
            append_effect_to_tower(effect, { toum_plus_stone = 1 })
            if effect.message == localize('k_plus_stone') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_plus_stone') then effect.extra.message = nil end
        end
        if effect.message == localize('k_plus_joker') or effect.extra and effect.extra.message == localize('k_plus_joker') then
            append_effect_to_tower(effect, { toum_plus_joker = 1 })
            if effect.message == localize('k_plus_joker') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_plus_joker') then effect.extra.message = nil end
        end
        amount = matches_localized(effect.message, 'a_hands') or effect.extra and matches_localized(effect.extra.message, 'a_hands')
        if amount then
            append_effect_to_tower(effect, { toum_plus_hands = primitive_number(math.min(amount, number(0.75))) }) -- apologies, but this infinite is not fun. you can cheese this with more than one scrapbook though, which is okay by me
            if matches_localized(effect.message, 'a_hands') then effect.message = nil end
            if effect.extra and matches_localized(effect.extra.message, 'a_hands') then effect.extra.message = nil end
        end
        if effect.message == localize('ph_boss_disabled') or effect.extra and effect.extra.message == localize('ph_boss_disabled') then
            append_effect_to_tower(effect, { toum_boss_disabled = 1 })
            if effect.message == localize('ph_boss_disabled') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('ph_boss_disabled') then effect.extra.message = nil end
        end
        if effect.message == localize('k_duplicated_ex') or effect.extra and effect.extra.message == localize('k_duplicated_ex') then
            append_effect_to_tower(effect, { toum_perkolate = 1 })
            if effect.message == localize('k_duplicated_ex') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_duplicated_ex') then effect.extra.message = nil end
        end
        if effect.message == localize('k_copied_ex') or effect.extra and effect.extra.message == localize('k_copied_ex') and effect.playing_cards_created then
            append_effect_to_tower(effect, { toum_first_played_copied = 1 })
            if effect.message == localize('k_copied_ex') then effect.message = nil end
            if effect.extra and effect.extra.message == localize('k_copied_ex') then effect.extra.message = nil end
            if effect.playing_cards_created then effect.playing_cards_created = nil end
        end
        if effect.playing_cards_created then effect.playing_cards_created = nil end
    end,
    set_ability = function(self, card, initial, delay_sprites)
        assert(card.ability)
        assert(card.ability.extra)
        card.ability.extra.remembered_effect = G.GAME.toum_last_sold_last_triggered_effect
        if card.ability.extra.remembered_effect then
            self.augment_effect(self, card, card.ability.extra.remembered_effect)
        end
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.toum_most_recent_trigger then
            local dangerous_classes = {
                Object, 
                Card, CardArea, Tag, Blind, Game, Controller, Event, EventManager, Node, Moveable,
                Card_Character, Particles, Sprite, DynaText, UIBox, UIElement, AnimatedSprite,
            }
            local effect_to_paste = copy_table_but_not_these_classes(context.card.ability.toum_most_recent_trigger, {Object})
            card.ability.extra.remembered_effect = remove_all_properties_of_type_recursively(effect_to_paste, 'function')
            local effect = card.ability.extra.remembered_effect
            if effect then
                self.augment_effect(self, card, effect)
            end
        end
        if context.joker_main then
            if card.ability.extra.remembered_effect then
                return card.ability.extra.remembered_effect
            end
        end
        -- correlated with the changes to make editions on retriggered jokers retrigger
        if context.retrigger_joker_check and card.ability.extra.remembered_effect and card.ability.extra.remembered_effect.toum_scrapbook_retrigger_self and context.other_card == card then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
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

SMODS.DrawStep {
    key = 'stickers_2',
    order = 41,
    func = function(self, layer)
        local center = self.config.center
        if center.reflect_stake_stickers then
            if self.sticker and G.shared_stickers[self.sticker] then
                local original_sticker_rotation = G.shared_stickers[self.sticker].T.r
                --G.shared_stickers[self.sticker].T.r = G.shared_stickers[self.sticker].T.r + math.pi
                --G.shared_stickers[self.sticker].role.draw_major = self
                G.shared_stickers[self.sticker]:draw_shader('dissolve', nil, nil, nil, self.children.center, nil, math.pi)
                G.shared_stickers[self.sticker]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center, nil, math.pi)
                --G.shared_stickers[self.sticker].T.r = original_sticker_rotation
            elseif (self.sticker_run and G.shared_stickers[self.sticker_run]) and G.SETTINGS.run_stake_stickers then
                local original_sticker_rotation = G.shared_stickers[self.sticker_run].T.r
                --G.shared_stickers[self.sticker_run].T.r = G.shared_stickers[self.sticker_run].T.r + math.pi
                --G.shared_stickers[self.sticker_run].role.draw_major = self
                G.shared_stickers[self.sticker_run]:draw_shader('dissolve', nil, nil, nil, self.children.center, nil, math.pi)
                G.shared_stickers[self.sticker_run]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center, nil, math.pi)
                --G.shared_stickers[self.sticker_run].T.r = original_sticker_rotation
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}


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
    atlas = "SpinToWin",
    pos = {v = 7, y = 0},
    cost = 2,
    --set_sprites = function(self, card, front)
    --    card.children.center
    --end,
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
    end,
    reflect_stake_stickers = true,
}



local function reverse_digits(n)
    local chips_string = tostring(n)
    chips_string = string.gsub(chips_string, ',', '')
    local digit_groups = {}
    for digit_group in string.gfind(chips_string, '[%d.]+') do
        digit_groups[digit_group] = true
    end
    for digit_group, v in pairs(digit_groups) do
        local decimal_index = string.find(digit_group, '%.')
        local reversed_digit_group = string.reverse(string.gsub(digit_group, '%.', ''))
        if decimal_index then
            reversed_digit_group = string.sub(reversed_digit_group, 1, decimal_index - 1) .. '.' .. string.sub(reversed_digit_group, decimal_index, #reversed_digit_group)
        end
        digit_groups[digit_group] = reversed_digit_group
        chips_string = string.gsub(chips_string, digit_group, reversed_digit_group, 1)
    end
    local chips_number = number(chips_string)
    return (chips_number)
end

local assert_equal = function(a, b, comparison, comparison_name)
    if comparison and comparison(a, b) then
        return
    end
    if (a == b) then
        return
    else
        error((
            'Assertion failed: '..
            'Expected '.. type(a).. ' ' .. tostring(a) .. ' to equal ' .. type(b) .. ' ' .. tostring(b) .. ' ' ..
            '(compared with '..(comparison and (comparison_name or 'a custom function') or '==')..') ' .. 
            num_to_str_full(a) .. ' vs ' .. num_to_str_full(b)
        ), 2)
    end
end

local assert_number_equal = function (a,b) return assert_equal(a, b, number_equal, 'number_equal') end
local assert_equal_with_tolerance = function (a,b,tolerance) return assert_equal(a, b, function(a,b) return number_equal_with_tolerance(a, b, tolerance) end, 'number_equal_with_tolerance('..tolerance..')') end

assert_equal(reverse_digits(number(1234567)), number(7654321))
assert_equal(reverse_digits(number(1.23)), number(3.21))
assert_equal(reverse_digits(number(1.6e87)), number(6.1e78))
assert_equal(reverse_digits(number(-1234567)), number(-7654321))

Airtokers.custom_effects.digit_reverse_chips = {
    core = function(amount)
        hand_chips = mod_chips(reverse_digits(hand_chips))
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
    if number_greater_than(x, number(-1)) and number_less_than(x, number(150)) and (((type(x) == 'number') and math.floor(x) == x) or ((type(x) == 'table') and (x.isint and x:isint()) or (x.floor and number_equal(x:floor(), x))) or number_equal(number_mod(x, number(1)), number(0))) then
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
        if number_not_equal(number_round_towards_positive_infinity(x), x) then
            return number(0)
        end
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

assert_equal(factorial(number(0)), number(1))
assert_equal(factorial(number(1)), number(1))
assert_equal(factorial(number(2)), number(2))
assert_equal(factorial(number(3)), number(6))
assert_equal_with_tolerance(factorial(number(4)), number(24), 0.00001)
assert_equal_with_tolerance(factorial(number(5)), number(120), 0.00001)
assert_equal_with_tolerance(factorial(number(50)), number(3.0414093e+64), 3.0414093e+58)
assert_equal_with_tolerance(factorial(number(0.5)), number(0.88622692545), 0.1)
assert_equal_with_tolerance(factorial(number(-0.5)), number(0.88622692545 / 0.5), 0.1)
assert_equal_with_tolerance(factorial(number(-1.5)), number(0.88622692545 / 0.5 / -0.5), 0.2)
assert_equal_with_tolerance(factorial(number(-2.5)), number(0.88622692545 / 0.5 / -0.5 / -1.5), 0.3)
assert_equal_with_tolerance(factorial(number(-20.5)), number(0), 0.00001)
assert_equal(factorial(number(-40.5)), number(0))
assert(number_not_equal(factorial(number(-70)), factorial(number(-70)))) -- nan

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

local function increase_digits(n)
    local chips_string = tostring(n)
    chips_string = string.gsub(chips_string, ',', '')
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
    return chips_number
end

assert_equal(increase_digits(number(10000)), number(21111))
assert_equal(increase_digits(number(6789)), number(78910))
assert_equal(increase_digits(number(99999)), number(1010101010))
assert_equal(increase_digits(number(-590)), number(-6101))
assert_equal(increase_digits(number(1.9)), number(2.10))
assert_equal_with_tolerance(increase_digits(number(5.4e19)), number(6.5e210), 1e201) -- good lord

Airtokers.custom_effects.increase_digits_chips = {
    core = function(amount)
        hand_chips = mod_chips(increase_digits(hand_chips))
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
        if number_equal_with_tolerance(number_mod(n, number(i)), number(0), 0.000001) or
           number_equal_with_tolerance(number_mod(n + number(0.000001), number(i)), number(0), 0.000001)
        then 
            return false
        end
        i = i + number(1)
    end
    return true
end

assert(is_prime(number(5)))
assert(is_prime(number(101)))
assert(is_prime(number(1979339339)))
assert(not is_prime(number(102221243011))) -- too big
assert(not is_prime(number(6)))
assert(not is_prime(number(60000000)))
assert(not is_prime(number(60000000000000000000000000000000000000)))

local function get_prime_factorization(n)
    n = math.abs(n)
    local prime_factorization =  {}
    local prime_index = 1
    local last_prime_index = #primes_up_to_1000000
    while number_greater_than(n, number(1)) and prime_index <= last_prime_index do
        while number_equal_with_tolerance(number_mod(n, number(primes_up_to_1000000[prime_index])), number(0), 0.000001) or
              number_equal_with_tolerance(number_mod(n + number(0.0000005), number(primes_up_to_1000000[prime_index])), number(0), 0.000001)
        do
            n = n / number(primes_up_to_1000000[prime_index])
            n = number_round_towards_positive_infinity(n)
            prime_factorization[primes_up_to_1000000[prime_index]] = (prime_factorization[primes_up_to_1000000[prime_index]] or 0) + 1
        end
        prime_index = prime_index + 1
    end
    return prime_factorization, n
end

assert((get_prime_factorization(number(50))[2] == 1))
assert((get_prime_factorization(number(50))[3] == nil))
assert((get_prime_factorization(number(50))[4] == nil))
assert((get_prime_factorization(number(50))[5] == 2))

assert((get_prime_factorization(number(8))[2] == 3))
assert((get_prime_factorization(number(8))[5] == nil))

assert((get_prime_factorization(number(80000))[2] == 7))
assert((get_prime_factorization(number(80000))[5] == 4))
assert((get_prime_factorization(number(120000))[2] == 6))
assert((get_prime_factorization(number(120000))[3] == 1))
assert((get_prime_factorization(number(120000))[5] == 4))


local eulers_totient_function_debug = function(m, m2) print(m, m2) end
eulers_totient_function_debug = function(m) end
local function eulers_totient_function(n)
    eulers_totient_function_debug('A', n)
    n = number_round_towards_positive_infinity(n)
    eulers_totient_function_debug('B', n)
    local original_n = n
    local original_sign = number(1)
    if is_negative(n) then
        original_sign = number(-1)
    end
    n = math.abs(n)
    eulers_totient_function_debug('C', n)
    if (number_greater_than(n, number(100000000))) then
        eulers_totient_function_debug('D')
        return original_n * number(6 / (math.pi ^ 2))
    end
    local prime_factorization, n = get_prime_factorization(n)
    eulers_totient_function_debug('E', type(prime_factorization) == 'table' and inspect(prime_factorization))
    eulers_totient_function_debug('F', n)
    if number_greater_than(n, number(1)) then
        if is_prime(n) then
            prime_factorization[n] = 1
        else
            eulers_totient_function_debug('G')
            return original_n * number(6 / (math.pi ^ 2))
        end
    end
    eulers_totient_function_debug('H', type(prime_factorization) == 'table' and inspect(prime_factorization))
    local product = number(1)
    for p, m in pairs(prime_factorization) do
        product = product * ((number(p) ^ number(m)) - (number(p) ^ (number(m) - number(1))))
    end
    eulers_totient_function_debug('I', product)
    eulers_totient_function_debug('J', original_sign)
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

assert(eulers_totient_function(number(5*5*5*2*2*2*2*3)))
-- 6000
--assert(number_equal(eulers_totient_function(number(5*5*5*2*2*2*2*3)), number(1600)))
assert_equal_with_tolerance(eulers_totient_function(number(5*5*5*2*2*2*2*3)), number(1600), 0.0001)
assert_equal_with_tolerance(eulers_totient_function(number(-27)), number(-18), 0.0001)
--print(eulers_totient_function(number(-27))) -- -18

-- shoutout to https://math.stackexchange.com/questions/1363950/average-lcma-b-1-le-a-le-b-le-n-and-asymptotic-behavior
-- for the formula (0.18269074235) * x^2
local function least_common_multiple(a, b)
    if is_zero(a) and is_zero(b) then
        return number(0)
    end
    if is_zero(a) or is_zero(b) then -- 0 and nonzero have no lcm (if it were zero, then lcm(2, 3) is 0 as well)
        return nan
    end
    if is_positive(a) ~= is_positive(b) then -- different signs implies no LCM (i am not counting -8 as a multiple of 2)
        return nan
    end
    if number_equal(a, b) then -- lcm(x, x) = x
        return a
    end
    local multiplied_by = number(1)
    if is_negative(a) then
        a = a * number(-1)
        b = b * number(-1)
        multiplied_by = multiplied_by * number(-1)
    end
    if number_equal(number_abs(a - b), number(1)) then -- two consecutive numbers are always coprime and share no factors, but lcm(-2, -3) is still -6
        return (a * b) * multiplied_by
    end
    for i = 1, 4 do -- lets us calculate LCM for rationals, truncated to 4 decimal digits if possible
        if number_less_than(a, number(1000000)) and number_less_than(b, number(1000000)) then
            a = a * number(10)
            b = b * number(10)
            multiplied_by = multiplied_by * number(10)
        end
    end
    -- algorithm only works for positive integers
    a = number_round_towards_positive_infinity(a)
    b = number_round_towards_positive_infinity(b)
    if (number_greater_than(a, number(100000000))) or (number_greater_than(b, number(100000000))) then
        return (a * b) * number(0.18269074235) / multiplied_by -- honestly probably a really shit approximation, this is a guess
    end
    local a_is_prime = is_prime(a)
    local b_is_prime = is_prime(b)
    if b_is_prime or a_is_prime then
        return (a * b) / multiplied_by
    end
    local prime_factorization_a, quotient_a = get_prime_factorization(a)
    local prime_factorization_b, quotient_b = get_prime_factorization(b)
    if number_greater_than(quotient_a, number(1)) then
        if is_prime(quotient_a) then
            prime_factorization_a[quotient_a] = 1
        else
            return (a * b) * number(0.18269074235) / multiplied_by
        end
    end
    if number_greater_than(quotient_b, number(1)) then
        if is_prime(quotient_b) then
            prime_factorization_b[quotient_b] = 1
        else
            return (a * b) * number(0.18269074235) / multiplied_by
        end
    end
    local lcm_prime_factorization = prime_factorization_a
    for p, b_m in pairs(prime_factorization_b) do
        local a_m = lcm_prime_factorization[p]
        lcm_prime_factorization[p] = math.max(a_m or 0, b_m) -- lcm(8, 12) is 24. 8 is 2*2*2 and 12 is 2*2*3, and 24 is 2*2*2*3.
    end
    local product = number(1)
    for p, m in pairs(lcm_prime_factorization) do
        product = product * (number(p) ^ number(m))
    end
    return product / multiplied_by
end

assert_equal_with_tolerance(least_common_multiple(number(2*2*2), number(2*2*3)), number(2*2*2*3), 0.000001)
assert_equal_with_tolerance(least_common_multiple(number(-6), number(-8)), number(-24), 0.000001)
assert_equal_with_tolerance(least_common_multiple(number(0.9), number(1.15)), number(20.7), 0.000001)
assert_equal_with_tolerance(least_common_multiple(number(0), number(0)), number(0), 0.000001)

Airtokers.custom_effects.lcm_mult = {
    core = function(amount)
        mult = mod_chips(least_common_multiple(mult, amount))
    end,
    mult = true,
    chips = false,
    translation_key = 'a_lcm_mult',
    colour = G.C.MULT,
    sound = 'multhit2',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

SMODS.Joker {
    key = 'eulers_curse',
    loc_txt = {
        name = "Euler's Curse",
        text = {
            "Applies {C:chips}Euler's totient function{} to Chips",
            "Applies {C:mult}Least common multiple with #1#{} to Mult"
        },
    },
    config = {
        extra = {
            lcm_mult = 4,
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.lcm_mult,
        } }
    end,
    rarity = 3,
    atlas = "Airtokers",
    pos = {x = 0, y = 2},
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                eulers_totient_function_chips = 1,
                extra = {
                    lcm_mult = card.ability.extra.lcm_mult
                },
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
            "Draw an {C:attention}extra hand{} of cards",
            "when opening a {C:attention}Booster Pack",
        },
    },
    config = {},
    loc_vars = function()
        
    end,
    rarity = 1,
    atlas = "CardRack",
    pos = {x = 1, y = 1},
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
    pos = {x = 2, y = 2},
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

-- allows cards to move while still in a cardarea card.with do_not_align_to_cardarea
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
    pos = {x = 3, y = 2},
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
    atlas = "Counterweight",
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

local function list_to_effect_tower(effects)
    if #effects == 0 then return nil end
    local working_effect = {}
    local total_effect = working_effect
    for i, effect in ipairs(effects) do
        if i ~= 1 then
            working_effect.extra = {}
            working_effect = working_effect.extra
        end
        for k, v in pairs(effect) do
            working_effect[k] = v
        end
    end
    return total_effect
end

assert(list_to_effect_tower({}) == nil)

assert(list_to_effect_tower({{a = 1}}).a == 1)

assert(list_to_effect_tower({{a = 1}, {b = 2}}).a == 1)
assert(list_to_effect_tower({{a = 1}, {b = 2}}).extra.b == 2)

assert(list_to_effect_tower({{a = 1, A = 2}, {b = 3, B = 4}}).a == 1)
assert(list_to_effect_tower({{a = 1, A = 2}, {b = 3, B = 4}}).A == 2)
assert(list_to_effect_tower({{a = 1, A = 2}, {b = 3, B = 4}}).extra.b == 3)
assert(list_to_effect_tower({{a = 1, A = 2}, {b = 3, B = 4}}).extra.B == 4)

assert(list_to_effect_tower({{a = 1}, {b = 2}, {c = 3}, {d = 4, D = 5}}).extra.extra.extra.d == 4)
assert(list_to_effect_tower({{a = 1}, {b = 2}, {c = 3}, {d = 4, D = 5}}).extra.extra.extra.D == 5)

--- A random cycle of ranks is setup for this seed. Each played card will have its rank set to the next in the cycle.
SMODS.Joker{
    key = 'transmutation',
    loc_txt = {
        name = "Transmutation",
        text = {
            "Every played card will transmute",
            "into another rank. Transmutations are",
            "consistent for the duration of this run.",
        },
    },
    config = {
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
        } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 4, y = 2},
    cost = 7,
    start_of_run_setup = function(self)
        G.GAME.toum_transmutation_mapping = {}
        local ranks = {}
        for k, v in pairs(SMODS.Ranks) do
            table.insert(ranks, v)
        end
        pseudoshuffle(ranks, pseudoseed('transmutation'))
        for i, v in ipairs(ranks) do
            print(tprint(v))
            G.GAME.toum_transmutation_mapping[ranks[i].key] = ranks[(i % #ranks) + 1].key
        end
    end,
    calculate = function(self, card, context)
        if context.before and context.full_hand and #context.full_hand > 1 then
            for i, card in ipairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.08,func = function() context.full_hand[i]:flip();play_sound('card1', percent);context.full_hand[i]:juice_up(0.3, 0.3);return true end }))
            end
            for i, card in ipairs(context.full_hand) do
                local original_base = card.base.value
                assert(SMODS.change_base(card, nil, G.GAME.toum_transmutation_mapping[original_base]), 'setting the base failed! you should punch airtoum')
                G.E_MANAGER:add_event(Event({blockable = false, trigger = 'immediate',func = function() 
                    assert(SMODS.change_base(card, nil, original_base), 'setting the base failed! you should punch airtoum')
                    return true
                end }))
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.08,func = function() 
                    assert(SMODS.change_base(card, nil, G.GAME.toum_transmutation_mapping[original_base]), 'setting the base failed! you should punch airtoum')
                    return true
                end }))
                --[[local next_effect = {}
                next_effect.func = function()
                    card:juice_up(0.5, 0.5)
                    play_sound('')
                    assert(SMODS.change_base(card, nil, G.GAME.toum_transmutation_mapping[card.base.value]), 'setting the base failed! you should punch airtoum')
                end
                table.insert(effects, next_effect)
                --]]
            end
            for i=1, #context.full_hand do
                local percent = 0.85 + (i-0.999)/(#context.full_hand-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.08,func = function() context.full_hand[i]:flip();play_sound('tarot2', percent, 0.6);context.full_hand[i]:juice_up(0.3, 0.3);return true end }))
            end
            return {}
        end
    end
}

local function reversed_table(t)
    local reversed = {}
    for i = #t, 1, -1 do
        table.insert(reversed, t[i])
    end
    return reversed
end
Airtokers.reversed_table = reversed_table

local function reverse_table(t)
    for i = 1, math.floor(#t / 2) do
        t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
    end
end
Airtokers.reverse_table = reverse_table


local original_smods_get_card_areas = SMODS.get_card_areas
SMODS.get_card_areas = function(_type, _context, a3, a4, a5, a6, a7, a8, a9)
    local return_value = original_smods_get_card_areas(_type, _context, a3, a4, a5, a6, a7, a8, a9)
    if next(find_joker('j_toum_antitime')) then
        return reversed_table(return_value)
    end
    return return_value
end


SMODS.Joker{
    key = 'antitime',
    loc_txt = {
        name = "Antitime",
        text = {
            "Scoring order is reversed",
        },
    },
    config = {
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
        } }
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 0, y = 3},
    cost = 4,
}

--[[
local original_g_funcs_hand_chip_ui_set = G.FUNCS.hand_chip_UI_set
G.FUNCS.hand_chip_UI_set = function(e)
    local return_value = original_g_funcs_hand_chip_ui_set(e)
    print('G.GAME.current_round.current_hand.chip_text: ', G.GAME.current_round.current_hand.chip_text)
    print('scale_number of negative: ', scale_number(-2, 0.9, 1000))
    return return_value
end
--]]

local integer_precision_limit = number(2 ^ 52)

Airtokers.custom_effects.x_odds = {
    core = function(amount)
        for k, v in pairs(G.GAME.probabilities) do 
            local unmodifided_probability = G.GAME.probabilities[k]
            local new_value = unmodifided_probability*amount
            if not number_greater_than(math.abs(new_value), integer_precision_limit) then
                G.GAME.probabilities[k] = new_value
                G.E_MANAGER:add_event(Event({
                    func = function(t)
                        G.E_MANAGER:add_event(Event({
                            func = function(t)
                                G.GAME.probabilities[k] = G.GAME.probabilities[k]/amount
                                return true
                            end,
                        }))
                        return true
                    end,
                }))
            end
        end
    end,
    mult = false,
    chips = false,
    misc = true,
    translation_key = 'a_x_odds',
    colour = G.C.GREEN,
    sound = 'multhit2',
    volume = 0.7,
    amt = nil,
    ['config.scale'] = 0.7,
}

Airtokers.custom_effects.plus_odds = {
    core = function(amount)
        for k, v in pairs(G.GAME.probabilities) do 
            local unmodifided_probability = G.GAME.probabilities[k]
            local new_value = v+amount
            if not number_greater_than(math.abs(new_value), integer_precision_limit) then
                G.GAME.probabilities[k] = new_value
                G.E_MANAGER:add_event(Event({
                    func = function(t)
                        G.E_MANAGER:add_event(Event({
                            func = function(t)
                                G.GAME.probabilities[k] = v-amount
                                return true
                            end,
                        }))
                        return true
                    end,
                }))
            end
        end
    end,
    mult = false,
    chips = false,
    misc = true,
    translation_key = 'a_plus_odds',
    colour = G.C.GREEN,
    sound = 'multhit1',
    volume = 0.7,
    amt = nil,
    ['config.scale'] = 0.7,
}

SMODS.Joker{
    key = 'seven_footed_rabbit',
    loc_txt = {
        name = "Seven-Footed Rabbit",
        text = {
            "When scored, each {C:attention}7{} has a {C:green}#2# in #3#{} chance",
            "to give {X:green,C:white}X#1#{} Odds to",
            "{C:attention}listed{} {C:green,E:1,S:1.1}probabilities{} for scored hand",
        },
    },
    config = {
        extra = {
            x_odds = 2,
            odds = 3,
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.x_odds,
            (G.GAME.probabilities.normal or 1) * 2,
            card.ability.extra.odds,
        } }
    end,
    rarity = 3,
    atlas = "Airtokers",
    pos = {x = 1, y = 3},
    cost = 1,
    calculate = function(self, card, context)
        if (
            context.individual and
            context.scoring_hand and
            context.other_card and
            SMODS.in_scoring(context.other_card, context.scoring_hand) and
            context.other_card:get_id() == 7 and
            pseudorandom('seven_footed_rabbit') < (G.GAME.probabilities.normal * 2) / card.ability.extra.odds
        ) then
            return {
                x_odds = card.ability.extra.x_odds,
                card = context.other_card,
            }
        end
    end,
}


SMODS.Joker {
    key = 'menu',
    loc_txt = {
        name = "Menu",
        text = {
            "{O:1}Converts Chips from {C:chips}Radians to degrees",
            "{O:2}Converts Chips from {C:chips}Degrees to radians",
            "{O:3}Applies {C:chips}Sign{} to Chips",
            "{O:4}Applies {C:chips}Successor{} to Chips",
            "{O:5,C:chips}Negates{} Chips",
            "{O:6,C:chips}Inverts digits{} in Chips",
            "{O:7,C:chips}Reverses digits{} in Chips",
            "{O:8}Applies {C:chips}Euler's totient function{} to Chips",
            "{O:9}Applies {C:chips}Absolute value{} to Chips",
            "{O:10,C:chips}Increments digits{} in Chips",
            "Effect changes after hand is played",
        },
    },
    config = {
        extra = {
            effect_choices = {
                { index = 1,  effect_type = 'rad_2_deg_chips',               amount = 1, }, -- good
                { index = 2,  effect_type = 'deg_2_rad_chips',               amount = 1, }, -- bad
                { index = 3,  effect_type = 'sign_chips',                    amount = 1, }, -- bad
                { index = 4,  effect_type = 'succ_chips',                    amount = 1, }, -- nothing
                { index = 5,  effect_type = 'negate_chips',                  amount = 1, }, -- bad
                { index = 6,  effect_type = 'digit_invert_chips',            amount = 1, }, -- good
                { index = 7,  effect_type = 'digit_reverse_chips',           amount = 1, }, -- good
                { index = 8,  effect_type = 'eulers_totient_function_chips', amount = 1, }, -- bad
                { index = 9,  effect_type = 'abs_chips',                     amount = 1, }, -- nothing
                { index = 10, effect_type = 'increase_digits_chips',         amount = 1, }, -- good
            },
            current_effect = nil,
        },
    },
    loc_vars = function(self, info_queue, card)
        local vars = {}
        card.ability.extra.current_effect = card.ability.extra.current_effect or { effect_type = 'message', amount = 'MISSING' }
        for i = 1, #card.ability.extra.effect_choices do
            table.insert(vars, card.ability.extra.current_effect.index ~= i)
        end
        return { vars = vars }
    end,
    rarity = 1,
    atlas = "Menu",
    pos = {x = 0, y = 0},
    display_size = { w = 71, h = 113 },
    --pixel_size = { w = 71, h = 113 },
    cost = 2,
    set_ability = function(self, card, initial, delay_sprites)
        G.E_MANAGER:add_event(Event({
            func = (function(t)
                card.ability.extra.current_effect = pseudorandom_element(card.ability.extra.effect_choices, pseudoseed('yeah_ill_get_uhhhhhhh'))
                return true
            end),
        }))
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if not card.ability.extra.current_effect then
                sendErrorMessage('Menu\'s current effect was nil', 'airtokers-menu')
                card.ability.extra.current_effect = { effect_type = 'message', amount = 'ERROR' }
            end
            return {
                [card.ability.extra.current_effect.effect_type] = card.ability.extra.current_effect.amount,
            }
        end
        if context.after then
            local choosable_effects = {}
            for i, v in ipairs(card.ability.extra.effect_choices) do
                if v ~= card.ability.extra.current_effect then
                    choosable_effects[#choosable_effects + 1] = v
                end
            end
            return {
                message = localize('k_reset'),
                colour = G.C.CHIPS,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card.ability.extra.current_effect = pseudorandom_element(choosable_effects, pseudoseed('yeah_ill_get_uhhhhhhh'))
                            return true
                        end,
                    }))
                end,
            }
        end
    end
}

local function radix_format(n, b)
    local place = -8
    n = n + b ^ (place - 2) -- floating point precision hack. add a speck more granular than this function will go
    for i= -8, 32 do
        if b ^ i > n then
            place = i - 1
            break
        end
    end
    local radix_string = place <= -1 and '0.' or ''
    local radix_string_truncated = radix_string
    while (place >= -8) do
        local digit = 0
        while (n - (digit + 1) * (b ^ place) >= 0) do
            digit = digit + 1
        end
        n = n - (digit)*(b ^ place)
        radix_string = radix_string .. digit
        radix_string_truncated = (place >= 0 or digit ~= 0) and radix_string or radix_string_truncated
        place = place - 1
        if place == -1 then
            radix_string = radix_string .. '.'
        end
    end
    return radix_string_truncated
end

local function convert_to_nonary(n)
    local chips_string = tostring(n)
    local digit_groups = {}
    for digit_group in string.gfind(chips_string, '[%d%.]+') do
        digit_groups[digit_group] = true
    end
    for digit_group, v in pairs(digit_groups) do
        local nonary_length = 0
        --while digit_group
        local nonary_digit_group = radix_format(tonumber(digit_group), 9)
        digit_groups[digit_group] = nonary_digit_group
        chips_string = string.gsub(chips_string, digit_group, nonary_digit_group, 1)
    end
    local status, chips_number_or_error = pcall(number, chips_string)
    local chips_number = nil
    if status then
        chips_number = chips_number_or_error
    else
        error('Airtokers convert_to_nonary failed to convert string '.. chips_string ..'  back into number: '.. chips_number_or_error)
    end
    assert(chips_number)
    return chips_number
end



assert_equal(convert_to_nonary(0.5), number(0.44444444))
assert_equal(convert_to_nonary(1/3), number(0.3))
assert_equal(convert_to_nonary(3000), number(4103))
assert_equal(convert_to_nonary(6561), number(10000))
assert_equal(convert_to_nonary(750.7), number(1023.62626262))
assert_equal(convert_to_nonary(-750.7), number(-1023.62626262))

local wrappedWithNullReturnWarning = function(original_func, name)
    assert(name)
    return function (a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
        local return_value = original_func(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
        if return_value == nil then
            sendWarnMessage(name..' may be being set to nil', 'Airtokers-nil-return-warning')
        end
        return return_value
    end
end

mod_chips = wrappedWithNullReturnWarning(mod_chips, 'Chips')
mod_mult = wrappedWithNullReturnWarning(mod_mult, 'Mult')


Airtokers.custom_effects.nonary_chips = {
    core = function(amount)
        hand_chips = mod_chips(convert_to_nonary(hand_chips))
    end,
    chips = true,
    mult = false,
    translation_key = 'a_nonary_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    ['config.scale'] = 0.6,
}


-- ineffecient algorithm but it will work
local function try_suit_set(suit_sets, target_func, prune_func, index, used_suits, num_used_suits)
    index = index or 1
    used_suits = used_suits or {}
    num_used_suits = num_used_suits or 0
    if prune_func and prune_func(num_used_suits) then
        return false
    end
    local suit_set = suit_sets[index]
    if suit_set == nil then
        return target_func(num_used_suits)
    end
    for _, suit in ipairs(suit_set) do
        local was_new_suit = false
        if not used_suits[suit] then
            was_new_suit = true
            num_used_suits = num_used_suits + 1
        end
        used_suits[suit] = true
        if try_suit_set(suit_sets, target_func, prune_func, index + 1, used_suits, num_used_suits) then
            return true
        else
            if was_new_suit then
                used_suits[suit] = false
                num_used_suits = num_used_suits - 1
            end
        end
    end
    if #suit_set == 0 then
        return try_suit_set(suit_sets, target_func, prune_func, index + 1, used_suits, num_used_suits)
    end
    return false
end

assert(try_suit_set({{'h'}, {'s','h'}, {'s','h','c','d'}, {'d'}}, function(n) return n == 3 end, function(n) return n > 3 end))
assert(try_suit_set({{'h'}, {'s','h'}, {'s','c'}, {'d'}, {'c'}}, function(n) return n == 3 end, function(n) return n > 3 end))
assert(not try_suit_set({{'h'}, {'s','h'}, {'s','c'}, {'d'}}, function(n) return n == 2 end, function(n) return n > 2 end))
assert(try_suit_set({{'h'}, {}, {'s','c'}, {}}, function(n) return n == 2 end, function(n) return n > 2 end))
assert(not try_suit_set({{'h'}, {}, {'s','c'}, {}}, function(n) return n == 3 end, function(n) return n > 3 end))
assert(not try_suit_set({{'h'}, {'h'}, {}, {'h'}, {}}, function(n) return n == 3 end, function(n) return n > 3 end))

-- actually treating it like "divisors" which has a slightly less vague definition (specifically for 0)
local function sum_of_factors(n)
    n = number_round_towards_positive_infinity(n)
    if is_zero(n) then
        return number(0)
    end
    local original_n = n
    local original_sign = number(1)
    if is_negative(n) then
        original_sign = number(-1)
    end
    n = math.abs(n)
    if (number_greater_than(n, number(100000000))) then
        return original_n * number(1.5) -- i eyeballed this off of https://oeis.org/A000203/graph
    end
    local prime_factorization, n = get_prime_factorization(n)
    if number_greater_than(n, number(1)) then
        if is_prime(n) then
            prime_factorization[n] = 1
        else
            return original_n * number(1.5)
        end
    end
    -- shoutouts to https://planetmath.org/formulaforsumofdivisors
    -- f(30) = 1 + 2 + 3 + 5 + 2*3 + 2*5 + 3*5 + 2*3*5
    -- f(30) = 1 + 3 + 5 + 3*5 + (2 + 2*3 + 2*5 + 2*3*5)
    -- f(30) = 1 + 3 + 5 + 3*5 + 2(2*(1-1) + 2*(3-1) + 2*(5-1) + 2*(3*5-1))
    -- factors(30) = product(powerset(prime_factors(30))), sorta
    -- f(12) = (2^0 * 3^0) + (2^1 * 3^0) + (2^2 * 3^0) + (2^0 * 3^1) + (2^1 * 3^1) + (2^2 * 3^1)
    -- f(12) = 1 + 2 + 4 + 3 + 6 + 12
    -- f(12) = (3^0) * ((2^0) + (2^1) + (2^2)) + (3^1) * ((2^0) + (2^1) + (2^2))
    -- ac + bc = c(a + b)
    -- f(12) = ((2^0) + (2^1) + (2^2))((3^0) + (3^1))
    -- 1, 3, 7, 15
    -- 1, 4, 13, 40
    -- 1, 5, 21, 85      
    -- 1 + 4 + 16 + 64 (+ 256)
    -- 256 = 64 + 16 + 4 + 1
    -- this image helped me understand this part https://upload.wikimedia.org/wikipedia/commons/f/fa/Geometric_progression_sum_visual_proof.svg
    -- f(12) = ((2^(2 + 1) - 1) / (2 - 1))((3^(1 + 1) - 1) / (3 - 1))
    local product = number(1)
    for p, m in pairs(prime_factorization) do
        product = product * (((number(p) ^ number(m + 1)) - number(1)) / (number(p) - number(1)))
    end
    return product * original_sign
end

--print(sum_of_factors(12))
assert_equal_with_tolerance(sum_of_factors(12), number(28), 0.000001)
assert_equal_with_tolerance(sum_of_factors(5), number(6), 0.000001)
assert_equal_with_tolerance(sum_of_factors(30), number(72), 0.000001)
--print(sum_of_factors(-40))
assert_equal_with_tolerance(sum_of_factors(-40), number(-90), 0.000001) -- 2,2,2,5 = 15 * 6
assert_equal_with_tolerance(sum_of_factors(1), number(1), 0.000001)
assert_equal_with_tolerance(sum_of_factors(-1), number(-1), 0.000001)
assert_equal_with_tolerance(sum_of_factors(0), number(0), 0.000001)

Airtokers.custom_effects.sum_of_factors_chips = {
    core = function(amount)
        hand_chips = mod_chips(sum_of_factors(hand_chips))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_sum_of_factors_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.koch_snowflake_chips = {
    core = function(amount)
        hand_chips = mod_chips(hand_chips ^ number(math.log(4, 3)))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_koch_snowflake_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.5,
}

Airtokers.custom_effects.plus_side_length_of_square_with_area_chips = {
    core = function(amount)
        hand_chips = mod_chips(hand_chips + math.sqrt(hand_chips))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_plus_side_length_of_square_with_area_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.37,
}

Airtokers.custom_effects.surface_area_of_a_cube_with_volume_chips = {
    core = function(amount)
        hand_chips = mod_chips(number(6) * (hand_chips ^ number(2/3)))
    end,
    mult = false,
    chips = true,
    translation_key = 'a_surface_area_of_a_cube_with_volume_chips',
    colour = G.C.CHIPS,
    sound = 'chips1',
    volume = 1,
    amt = nil,
    ['config.scale'] = 0.37,
}

SMODS.Joker {
    key = 'receipt',
    loc_txt = {
        name = "Receipt",
        text = {
            "Gains a random effect", -- 1
            "when you purchase a {C:attention}Voucher", -- 2
            "When played hand has exactly {C:attention}3 suits{}:", -- 3
            "Converts Chips to {C:chips}Nonary", -- 4
            "{C:chips}Increments digits{} in Chips", -- 5
            "Sets Chips to the {C:chips}Sum of its divisors", --6
            "Sets Chips to the {C:chips}Measure of a Chips-sized Koch Snowflake", -- 7
            "{C:chips}#1#{} Chips", -- 8
            "Sets Chips to the {C:chips}Surface area of a Chips-volume cube", -- 9
        },
    },
    effect_formatters = {
        velocitize,
    },
    effect_choices = {
        { index = 1, dict_index = 4, effect_type = 'nonary_chips', amount = 1, },
        { index = 2, dict_index = 5, effect_type = 'increase_digits_chips', amount = 1, },
        { index = 3, dict_index = 6, effect_type = 'sum_of_factors_chips', amount = 1, },
        { index = 5, dict_index = 8, effect_type = 'chips', amount = 30, formatter = velocitize },
        { index = 6, dict_index = 9, effect_type = 'surface_area_of_a_cube_with_volume_chips', amount = 1, },
    },
    rare_effect_choices = {
        { index = 4, dict_index = 7, effect_type = 'koch_snowflake_chips', amount = 1, },
    },
    normal_effect_rate = 9,
    rare_effect_rate = 1,
    config = {
        extra = {
            effect_list = {

            },
        },
    },
    loc_vars = function(self, info_queue, card)
        local vars = {
            dictionary_indices = {1, 2, 3},
            line_vars = {{},{},{}},
        }
        for i, effect in ipairs(card.ability.extra.effect_list) do
            table.insert(vars.dictionary_indices, effect.dict_index)
            table.insert(vars.line_vars, {(self.effect_formatters[effect.formatter_index] or identity)(effect.amount)})
        end
        return { 
            vars = vars,
        }
    end,
    add_effect = function(self, card)
        local pool_of_choices = { { index = 1, dict_index = 1, effect_type = 'message', amount = 'error', }, }
        local pools = {
            { rate = self.normal_effect_rate, choices = self.effect_choices },
            { rate = self.rare_effect_rate, choices = self.rare_effect_choices }
        }
        local total_rate = 0
        for i, v in ipairs(pools) do
            total_rate = total_rate + v.rate
        end
        -- pseudorandom returns on interval of [0..1)
        local polled_rate = (pseudorandom(pseudoseed('receipt_rarity'))) * total_rate
        local check_rate = 0
        for i, v in ipairs(pools) do        
            if polled_rate >= check_rate and polled_rate < check_rate + v.rate then
                pool_of_choices = v.choices
                break
            end 
            check_rate = check_rate + v.rate
        end
        local added_effect = pseudorandom_element(pool_of_choices, pseudoseed('receipt'))
        -- create a different instance of the table
        added_effect = {
            dict_index = added_effect.dict_index,
            effect_type = added_effect.effect_type,
            amount = added_effect.amount,
            formatter_index = index_of(self.effect_formatters, added_effect.formatter) or 0,
        }
        table.insert(card.ability.extra.effect_list, added_effect)
    end,
    rarity = 2,
    atlas = "Airtokers",
    pos = {x = 3, y = 3},
    cost = 9,
    set_ability = function(self, card, initial, delay_sprites)
        G.E_MANAGER:add_event(Event({
            func = (function(t)
                self:add_effect(card)
                return true
            end),
        }))
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == 'Voucher' then
            self:add_effect(card)
        end
        if context.joker_main then
            local suit_sets = {}
            for i, played_card in ipairs(context.full_hand) do
                local played_card_suit_set = {}
                for k, v in pairs(SMODS.Suits) do
                    if played_card:is_suit(v.key) then
                        table.insert(played_card_suit_set, v.key)
                    end
                end
                table.insert(suit_sets, played_card_suit_set)
            end
            if try_suit_set(suit_sets, function(n) return n == 3 end, function(n) return n > 3 end) then
                local effects = {}
                for i, effect in ipairs(card.ability.extra.effect_list) do
                    table.insert(effects, { [effect.effect_type] = effect.amount })
                end
                return list_to_effect_tower(effects)
            end
        end
    end
}

--- Apply Rental to a random joker if played hand contains no Spades. Convert chips from radians to degrees if played hand contains no Spades.
--- Gains +1 Chips when joker to the right is triggered. Gains -1 Chips joker to the left is triggered. Does nothing if not between two jokers.
--- After first played hand is played and scored, it is played and scored again
--- Each played 7 giveds x2 Odds for the scored hand
--- Gains +1 Odds when a Spectral card is used (Currently +0 to all listed probabilities)
--- This joker contains a chip score box times a grey mult box. Whenever a chip effect happens, it also happens to the value within this card's chip score box.
------ When this Joker is scored, its chips and grey mult get multiplied together, and then added to your round score, and then they reset.
------ After normal scoring ends, the numbers in this card do not reset, so you may desync this chips with the normal chips.
------ Setting chips from selecting a hand only updates this card's chip score when this card's chip score is 0.
--- A joker that makes things a lot cheaper, but "turns off the lights." Do `SMODS.DrawSteps['center'].func = function() end` to see what I mean



--- final setups!

for _, func in ipairs(final_setups) do
    func()
end

----------------------------------------------
------------MOD CODE END----------------------
