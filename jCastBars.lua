-- locals and speed
local AddonName, Addon = ...;

local pairs = pairs;
local max = math.max;

local UPDATE_DELAY = .2;

-- main
function Addon:Load()
  do
    local eventHandler = CreateFrame('Frame', nil);

    -- set OnEvent handler
    eventHandler:SetScript('OnEvent', function(handler, ...)
        self:OnEvent(...);
      end)

    eventHandler:RegisterEvent('PLAYER_LOGIN');
  end
end

-- frame events
function Addon:OnEvent(event, ...)
  local action = self[event];

  if (action) then
    action(self, event, ...);
  end
end

function Addon:PLAYER_LOGIN()
  self:SetupCastBarText();
  self:HookActionEvents();
end

-- configuration
function Addon:SetupCastBarText()
  for _, frame in pairs({
      CastingBarFrame,
      TargetFrameSpellBar
    }) do
    frame.castText = frame:CreateFontString(nil, 'ARTWORK');
    frame.castText:SetFontObject('GameFontHighlight');
    frame.castText:SetPoint('TOP', frame, 'BOTTOM', 0, -5);

    frame.remain = UPDATE_DELAY;
  end
end

-- hooks
do
  local function Frame_UpdateStatus(frame, elapsed)
    Addon:UpdateStatus(frame, elapsed);
  end

  function Addon:HookActionEvents()
    CastingBarFrame:HookScript('OnUpdate', Frame_UpdateStatus);
    TargetFrameSpellBar:HookScript('OnUpdate', Frame_UpdateStatus);
  end
end

function Addon:UpdateStatus(frame, elapsed)
  if (frame.remain) then
    frame.remain = frame.remain + elapsed;

    if (frame.remain > UPDATE_DELAY) then
      frame.remain = 0;
      self:UpdateCastBarText(frame);
    end
  end
end

function Addon:UpdateCastBarText(frame)
  if (frame.casting and frame.value <= frame.maxValue) then
    frame.castText:SetFormattedText('%2.1f/%1.1f', max(frame.maxValue - frame.value, 0), frame.maxValue);
  elseif (frame.channeling and frame.value >= 0) then
    frame.castText:SetFormattedText('%.1f', max(frame.value, 0));
  else
    frame.castText:SetText(nil);
  end
end

-- call
Addon:Load();
