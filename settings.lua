-- ╔══════════════════════════════════════════════════════════════╗
-- ║                      settings.lua                           ║
-- ║              PanelBase · Session Info Module                ║
-- ╚══════════════════════════════════════════════════════════════╝

local HttpService = game:GetService("HttpService")

-- ──────────────────────────────────────────────────────────────
--  MODULE
-- ──────────────────────────────────────────────────────────────

local Settings = {}

-- ──────────────────────────────────────────────────────────────
--  COLOR PALETTE  (matched to reference image)
-- ──────────────────────────────────────────────────────────────
--
--   HEADER_BG  ██  RGB( 17,  16,  15)  near-black warm
--   CARD_BG    ██  RGB( 26,  25,  23)  dark warm gray
--   FIELD_BG   ██  RGB( 38,  36,  34)  raised control surface
--   ACCENT     ██  RGB(200,  55,  50)  warm red  (icon / badge)
--   WHITE      ██  RGB(208, 205, 200)  warm off-white
--   GRAY       ██  RGB(112, 108, 102)  muted label gray
--   MUTED      ██  RGB( 55,  52,  48)  faint interactive gray
--   GREEN      ██  RGB( 82, 200,  95)  active / lifetime expiry

Settings.C = {
    WIN       = Color3.fromRGB( 20,  19,  18),
    TBAR      = Color3.fromRGB( 15,  14,  13),
    LINE      = Color3.fromRGB( 45,  43,  40),
    ACCENT    = Color3.fromRGB(200,  55,  50),   -- warm red
    HEADER_BG = Color3.fromRGB( 17,  16,  15),   -- near-black
    CARD_BG   = Color3.fromRGB( 26,  25,  23),   -- dark warm gray
    FIELD_BG  = Color3.fromRGB( 38,  36,  34),   -- raised surface
    NAV       = Color3.fromRGB( 13,  12,  11),
    NAVPIL    = Color3.fromRGB( 28,  26,  24),
    WHITE     = Color3.fromRGB(208, 205, 200),   -- warm off-white
    GRAY      = Color3.fromRGB(112, 108, 102),   -- muted label
    MUTED     = Color3.fromRGB( 55,  52,  48),   -- faint gray
    GREEN     = Color3.fromRGB( 82, 200,  95),   -- expiry active
}

-- ──────────────────────────────────────────────────────────────
--  LAYOUT CONSTANTS
-- ──────────────────────────────────────────────────────────────

Settings.Layout = {
    WW   = 540,
    WH   = 440,
    TH   =  42,
    NW   = 246,
    NH   =  46,
    NGAP =  14,
    BH   = 440 - 42,
}

-- ──────────────────────────────────────────────────────────────
--  BUILD
-- ──────────────────────────────────────────────────────────────

function Settings.build(page, r)

    local C       = Settings.C
    local mk      = r.mk
    local rnd     = r.rnd
    local tw      = r.tw
    local isAdmin = r.isAdmin or false

    local accentEls = {}

    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    local expiryLabelRef  = nil
    local fullExpiryText  = ""
    local shortExpiryText = ""

    local function registerAccent(element, property)
        table.insert(accentEls, { el = element, prop = property })
    end

    -- ──────────────────────────────────────────────────────────
    --  HELPER · Info Row
    --    label ──────────────── [ value box ]
    -- ──────────────────────────────────────────────────────────

    local function makeInfoRow(parent, label, value, icon, isPassword, layoutOrder, valueColor)

        local row = mk("Frame", {
            Size                   = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            LayoutOrder            = layoutOrder,
        }, parent)

        -- Left label
        mk("TextLabel", {
            Text                   = label,
            Font                   = Enum.Font.GothamBold,
            TextSize               = 10,
            TextColor3             = C.GRAY,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.42, 0, 1, 0),
            Position               = UDim2.new(0, 0, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 5,
        }, row)

        -- Right value box — raised surface, no stroke
        local valBox = mk("Frame", {
            Size             = UDim2.new(0.58, 0, 0, 24),
            Position         = UDim2.new(0.42, 0, 0.5, -12),
            BackgroundColor3 = C.FIELD_BG,
            BorderSizePixel  = 0,
            ZIndex           = 5,
        }, row)
        rnd(5, valBox)

        -- Icon
        if icon then
            local img = mk("ImageLabel", {
                Image                  = icon,
                Size                   = UDim2.new(0, 11, 0, 11),
                Position               = UDim2.new(0, 7, 0.5, -5),
                BackgroundTransparency = 1,
                ImageColor3            = C.ACCENT,
                ZIndex                 = 6,
            }, valBox)
            registerAccent(img, "ImageColor3")
        end

        local displayText = isPassword and string.rep("•", math.min(#value, 16)) or value
        local xOffset     = icon and 23 or 8
        local xSize       = isPassword and -50 or (icon and -26 or -14)

        local textLbl = mk("TextLabel", {
            Text                   = displayText,
            Font                   = Enum.Font.Code,
            TextSize               = 9,
            TextColor3             = valueColor or C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, xSize, 1, 0),
            Position               = UDim2.new(0, xOffset, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextTruncate           = Enum.TextTruncate.AtEnd,
            ZIndex                 = 6,
        }, valBox)

        -- Password toggle
        if isPassword then
            local visible = false
            local eyeBtn = mk("TextButton", {
                Text                   = "○",
                Font                   = Enum.Font.GothamBold,
                TextSize               = 9,
                TextColor3             = C.MUTED,
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0, 22, 1, 0),
                Position               = UDim2.new(1, -24, 0, 0),
                ZIndex                 = 7,
                AutoButtonColor        = false,
            }, valBox)
            eyeBtn.MouseButton1Click:Connect(function()
                visible      = not visible
                textLbl.Text = visible and value or displayText
                eyeBtn.Text  = visible and "●" or "○"
                tw(eyeBtn, 0.12, { TextColor3 = visible and C.ACCENT or C.MUTED })
            end)
            eyeBtn.MouseEnter:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.GRAY }) end
            end)
            eyeBtn.MouseLeave:Connect(function()
                if not visible then tw(eyeBtn, 0.1, { TextColor3 = C.MUTED }) end
            end)
        end

        return textLbl
    end

    -- ──────────────────────────────────────────────────────────
    --  SESSION INFO
    -- ──────────────────────────────────────────────────────────

    local function buildSessionInfo(parent)

        local SAVE_FILE = "serios_saved.json"
        local canRead   = typeof(readfile) == "function" and typeof(isfile) == "function"

        local username, key, expiry = "N/A", "N/A", "N/A"
        local isLifetime = false

        if canRead then
            local ok, result = pcall(function()
                if not isfile(SAVE_FILE) then return nil end
                return HttpService:JSONDecode(readfile(SAVE_FILE))
            end)
            if ok and result and result.username and result.key then
                username = result.username
                key      = result.key
                expiry   = result.expiry or "N/A"
            else
                username = "Not Found"
                key      = "Not Found"
            end
        end

        local function formatShort(exp)
            if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
            if exp == "lifetime" then isLifetime = true; return "Lifetime" end
            local ts = tonumber(exp)
            if ts then
                local d = os.date("*t", ts)
                return string.format("%02d/%02d/%04d", d.day, d.month, d.year)
            end
            return tostring(exp)
        end

        local function formatFull(exp)
            if not exp or exp == "N/A" or exp == "Not Found" then return "N/A" end
            if exp == "lifetime" then return "Lifetime (no expiry)" end
            local ts = tonumber(exp)
            if ts then
                local d = os.date("*t", ts)
                return string.format(
                    "%02d/%02d/%04d  %02d:%02d:%02d",
                    d.day, d.month, d.year,
                    d.hour, d.min, d.sec
                )
            end
            return tostring(exp)
        end

        shortExpiryText = formatShort(expiry)
        fullExpiryText  = formatFull(expiry)

        local expiryColor = (isLifetime or isAdmin)
            and C.WHITE
            or  C.GREEN

        local lo = 0
        local function lo_next() lo = lo + 1; return lo end

        makeInfoRow(parent, "Username", username,        "rbxassetid://75066739039083",  false, lo_next(), nil)
        makeInfoRow(parent, "Key",      key,             "rbxassetid://126448589402910", true,  lo_next(), nil)
        expiryLabelRef =
        makeInfoRow(parent, "Expiry",   shortExpiryText, "rbxassetid://78475382175834",  false, lo_next(), expiryColor)
    end

    -- ──────────────────────────────────────────────────────────
    --  PAGE ASSEMBLY
    -- ──────────────────────────────────────────────────────────

    task.delay(1, function()

        mk("UIListLayout", {
            Padding   = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        mk("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
        }, page)

        -- ┌─────────────────────────────────────────────────┐
        -- │  Session Info Card                              │
        -- └─────────────────────────────────────────────────┘

        -- Card body  (CARD_BG — dark warm gray)
        local panel = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.CARD_BG,
            BorderSizePixel  = 0,
            LayoutOrder      = nextOrder(),
        }, page)
        rnd(7, panel)

        -- Header  (HEADER_BG — near-black, clear contrast)
        local header = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = C.HEADER_BG,
            BorderSizePixel  = 0,
            ZIndex           = 4,
            ClipsDescendants = true,
        }, panel)
        rnd(7, header)

        -- Square off the bottom edge of the rounded header
        mk("Frame", {
            Size             = UDim2.new(1, 0, 0.5, 0),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = C.HEADER_BG,
            BorderSizePixel  = 0,
            ZIndex           = 3,
        }, header)

        -- Title
        mk("TextLabel", {
            Text                   = "Session Info",
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            TextColor3             = C.WHITE,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, -36, 1, 0),
            Position               = UDim2.new(0, 12, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 6,
        }, header)

        -- Accent icon — top right corner (warm red, like reference)
        local headerIcon = mk("ImageLabel", {
            Image                  = "rbxassetid://78475382175834",
            Size                   = UDim2.new(0, 11, 0, 11),
            Position               = UDim2.new(1, -19, 0.5, -5),
            BackgroundTransparency = 1,
            ImageColor3            = C.ACCENT,
            ZIndex                 = 7,
        }, header)
        registerAccent(headerIcon, "ImageColor3")

        -- Content area
        local content = mk("Frame", {
            Size                   = UDim2.new(1, -24, 0, 0),
            Position               = UDim2.new(0, 12, 0, 44),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, panel)

        mk("UIListLayout", {
            Padding   = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, content)

        mk("UIPadding", { PaddingBottom = UDim.new(0, 12) }, panel)

        buildSessionInfo(content)
    end)
end

return Settings
