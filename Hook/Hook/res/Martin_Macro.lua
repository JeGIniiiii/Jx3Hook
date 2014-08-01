Martin_Macro = {}
--Martin_Macro.bChannel = false
Martin_Macro.nStepper = 0

Martin_Macro.nSkilldwID = 0
Martin_Macro.nSkillLevel = 0


--�ж��Լ��ͷż���
function Martin_Macro.MySkill(PlayerID,SkillID,SkillLv)
	local player = GetClientPlayer()

	if player.dwID == PlayerID then
        Martin_Macro.nSkilldwID = SkillID
        Martin_Macro.nSkillLevel = SkillLv
	end
end

--ע�Ἴ�ܼ���¼�
RegisterEvent("SYS_MSG", function()
	if arg0 == "UI_OME_SKILL_HIT_LOG" and arg3 == SKILL_EFFECT_TYPE.SKILL then
		Martin_Macro.MySkill(arg1, arg4, arg5)
	elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" and arg4 == SKILL_EFFECT_TYPE.SKILL then
		Martin_Macro.MySkill(arg1, arg5, arg6)
	elseif (arg0 == "UI_OME_SKILL_BLOCK_LOG" or arg0 == "UI_OME_SKILL_SHIELD_LOG" or arg0 == "UI_OME_SKILL_MISS_LOG" or arg0 == "UI_OME_SKILL_DODGE_LOG") and arg3 == SKILL_EFFECT_TYPE.SKILL then
		Martin_Macro.MySkill(arg1, arg4, arg5)
	end
end)

function Martin_Macro.CheckCast(szSkillName)
    if Table_GetSkillName(Martin_Macro.nSkilldwID,Martin_Macro.nSkillLevel) == "szSkillName" then
        return true
    end

	return false
end


--����ָ��BUFF ID�ж϶����Ƿ���BUFF
function Martin_Macro.BuffChackById(hPlayer, dwBUFFID)
	if hPlayer then
        for i = 1,hPlayer.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
            if dwID == dwBUFFID then--ָ��BUFF
                return nStackNum
            end
        end
	end

    return 0
end

--����ָ��BUFF Name�ж϶����Ƿ���BUFF
function Martin_Macro.BuffChackByName(hPlayer, szBuffName, bMbuff)
	if hPlayer then
        if bMbuff == false then
            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                     return true
                end
            end
        else
            for i = 1,hPlayer.GetBuffCount(),1 do
                local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = hPlayer.GetBuff(i - 1)
                if GetClientPlayer().dwID == dwSkillSrcID then
                    if Table_GetBuffName(dwID, nLevel) == szBuffName then
                         return true
                    end
                end
            end
        end
    

	end
    return false
end

--ͨ����������ȡ����ID �ȼ�
function Martin_Macro.GetSkillID(szSkillName)
	--local hPlayer = GetClientPlayer()
	--local aSkill = hPlayer.GetAllSkillList() or {}
	--for k, v in pairs(aSkill) do
		--local szName = Table_GetSkillName(k, v)
        --if szSkillName == szName then
			--return k, v
		--end
	--end
    local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
    local nSkillLv = player.GetSkillLevel(nSkillID)
	return nSkillID, nSkillLv

end

-- ����Ŀ����룬������ӵ�GetDistanceֻ���ж�ˮƽ���߶Ȳ�������
function Martin_Macro.MyGetDistance(szRule, nDce)
	local player = GetClientPlayer()
	local ttp,tid = player.GetTarget()
	local tplayer = GetTargetHandle(ttp,tid)
	if tplayer then
		local distance = math.floor(((player.nX - tplayer.nX) ^ 2 + (player.nY - tplayer.nY) ^ 2 + (player.nZ/8 - tplayer.nZ/8) ^ 2) ^ 0.5)/64
        nDce = tonumber(("%.2f"):format(nDce))
        if szRule == "=" then
            if distance == nDce then
                return true
            end  
        elseif szRule == ">" then            
            if distance > nDce then
                return true
            end
        elseif szRule == "<" then
            if distance < nDce then
                return true
            end
        elseif szRule == "=" then
            if distance == nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        elseif szRule == "<=" then
            if distance <= nDce then
                return true
            end
        end
        
        return false
	end
end

--����ת��ǶȲ�ת��Ŀ��
function Martin_Macro.FaceToTarget()
        local player = GetClientPlayer()
        local ttp,tid = player.GetTarget()
        if tid == 0 or tid == player.dwID then
            return
        end
        
        local tplayer = GetTargetHandle(ttp,tid)  
        local tanX = tplayer.nX - player.nX
        local tanY = tplayer.nY - player.nY

        TurnTo(math.atan2(tanY,tanX)*128/math.pi)
end

--�Ƿ��ڶ���
function Martin_Macro.CheckSkillPrepare(szRule, szSkillName)

    szSkillName = szSkillName or ""

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    local bPrepare, dwID, nLevel, nFrameProgress

    if szRule == "prepare" then 
		bPrepare, dwID, nLevel, nFrameProgress = player.GetSkillPrepareState() 
	elseif szRule == "tprepare" and target then
		bPrepare, dwID, nLevel, nFrameProgress = target.GetSkillPrepareState()
	end

    if szSkillName == "" then
        return bPrepare
    elseif Table_GetSkillName(dwID,nLevel) == szSkillName then
        return true
    end

    return false
end

--buff��
function Martin_Macro.CheckBuff(szRule,szBuffName)
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule =="buff" then
        return Martin_Macro.BuffChackByName(player, szBuffName, false)

	elseif szRule =="nobuff" then
        return not Martin_Macro.BuffChackByName(player, szBuffName, false)

	elseif szRule == "tbuff" and target then
        return Martin_Macro.BuffChackByName(target, szBuffName, false)

	elseif szRule == "tnobuff" and target then
        return not Martin_Macro.BuffChackByName(target, szBuffName, false)

    elseif szRule == "mbuff" and target then
        return Martin_Macro.BuffChackByName(target, szBuffName, true)

    elseif szRule == "nombuff" and target then
        return not Martin_Macro.BuffChackByName(target, szBuffName, true)
	end

    return false
end

function Martin_Macro.CheckBuffTime(szRule,szBuffName,szSym,nTime)
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    local dummy
    local bMbuff = false

    if szRule == "bufftime" then
        dummy = player
    elseif szRule == "tbufftime" then
        dummy = target
    elseif szRule == "mbufftime" then
        dummy = target
        bMbuff = true
    end

    if bMbuff == false then
        for i = 1,dummy.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
            if Table_GetBuffName(dwID, nLevel) == szBuffName then
                local nTimeLeft = tonumber(("%.2f"):format((nEndFrame - GetLogicFrameCount())/16))
                if szSym == ">" then
                    if nTimeLeft > tonumber(nTime) then
                        return true
                    end
                elseif szSym == "<" then
                    if nTimeLeft < tonumber(nTime) then
                        return true
                    end
                elseif szSym == "=" then
                    if nTimeLeft == tonumber(nTime) then
                        return true
                    end
                elseif szSym == "<=" then
                    if nTimeLeft <= tonumber(nTime) then
                        return true
                    end
                elseif szSym == ">=" then
                    if nTimeLeft >= tonumber(nTime) then
                        return true
                    end
                end
            end
        end
    else
        for i = 1,dummy.GetBuffCount(),1 do
            local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = dummy.GetBuff(i - 1)
            if  dwSkillSrcID == player.dwID then
                if Table_GetBuffName(dwID, nLevel) == szBuffName then
                    local nTimeLeft = tonumber(("%.2f"):format((nEndFrame - GetLogicFrameCount())/16))
                    if szSym == ">" then
                        if nTimeLeft > tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "<" then
                        if nTimeLeft < tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "=" then
                        if nTimeLeft == tonumber(nTime) then
                            return true
                        end
                    elseif szSym == "<=" then
                        if nTimeLeft <= tonumber(nTime) then
                            return true
                        end
                    elseif szSym == ">=" then
                        if nTimeLeft >= tonumber(nTime) then
                            return true
                        end
                    end
                end
            end
        end
    end



	return false

end

--����Ƿ�������
function Martin_Macro.CheckHorse(szRule)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "horse" then
		if player.bOnHorse then
			return true
		end
	elseif szRule == "nohorse" then
		if not player.bOnHorse then
			return true
		end
	elseif szRule == "thorse" and target then
		if target.bOnHorse then
			return true
		end
	elseif szRule == "tnohorse" and target then
		if not target.bOnHorse then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckFight(szRule)
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "fight" then
		if player.bFightState then
			return true
		end
	elseif szRule == "nofight" then
		if not player.bFightState then
			return true
		end
	elseif szRule == "tfight" and target then
		if target.bFightState then
			return true
		end
	elseif szRule == "tnofight" and target then
		if not target.bFightState then
			return true
		end
	end
	return false
end

--cd��
function Martin_Macro.CheckSkillCD(szRule,szSkillName)
	local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
	local bCool,nLeft,nTotal = player.GetSkillCDProgress(nSkillID,player.GetSkillLevel(nSkillID))

	if szRule == "cd" then
		if nLeft > 0 then
			return true
		end
	elseif szRule == "nocd" then
		if nLeft == 0 then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckSkillCDTime(szSkillName,szRule,nTime)
	local player = GetClientPlayer()
	local nSkillID = g_SkillNameToID[szSkillName]
	local bCool,nLeft,nTotal = player.GetSkillCDProgress(nSkillID,player.GetSkillLevel(nSkillID))

    nLeft = nLeft / 16

	if szRule == "<" then
		if nLeft < nTime then
			return true
		end
	elseif szRule == ">" then
		if nLeft > nTime then
			return true
		end
	elseif szRule == "=" then
		if nLeft == nTime then
			return true
		end
	elseif szRule == "<=" then
		if nLeft <= nTime then
			return true
		end
	elseif szRule == ">=" then
		if nLeft >= nTime then
			return true
		end
    end

	return false

end

--������ֵ״̬��
function Martin_Macro.CheckCharacterPointValue(szRule,szSym,szValue)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
    
	local dummycurrent
	local dummymax

	if szRule == "life" then
		dummycurrent = player.nCurrentLife
		dummymax = player.nMaxLife
	elseif szRule == "tlife" and target then
		dummycurrent = target.nCurrentLife
		dummymax = target.nMaxLife
	elseif szRule == "mana" then
		dummycurrent = player.nCurrentMana
		dummymax = player.nMaxMana
	elseif szRule == "tmana" and target then
		dummycurrent = target.nCurrentMana
		dummymax = target.nMaxMana
	elseif szRule == "power" then
		dummycurrent = player.nAccumulateValue
		if player.dwForceID == 1 then --����
			dummymax = 3
		elseif player.dwForceID == 4 then --����
			dummymax = 10
		end
	elseif szRule == "rage" then
		dummycurrent = player.nCurrentRage
		dummymax = player.nMaxRage
	elseif szRule == "dance" then
        dummycurrent = Martin_Macro.BuffChackById(player, 409)
		dummymax = 10
	elseif szRule == "energy" then
		dummycurrent = player.nCurrentEnergy
		dummymax = player.nMaxEnergy
	elseif szRule == "solar" then
		dummycurrent = player.nCurrentSunEnergy
		dummymax = player.nMaxSunEnergy
	elseif szRule == "luna" then
		dummycurrent = player.nCurrentMoonEnergy
		dummymax = player.nMaxMoonEnergy
	elseif szRule == "flypower" then
		dummycurrent = player.nSprintPower
		dummymax = player.nSprintPowerMax
	end

	local dummy = dummycurrent/dummymax

	if szValue == "1.0" or szValue == "1" then
		dummy = tonumber(("%.2f"):format(dummy))
	elseif tonumber(szValue) >= 1 then
		dummy = dummycurrent
	else
		dummy = tonumber(("%.2f"):format(dummy))
	end

	local nValue = tonumber(szValue)

	if szSym == ">" then
		if dummy > nValue then
			return true
		end
	elseif szSym == "<" then
		if dummy < nValue then
			return true
		end
	elseif szSym == "=" then
		if dummy == nValue then
			return true
		end
	elseif szSym == "<=" then
		if dummy <= nValue then
			return true
		end
	elseif szSym == ">=" then
		if dummy >= nValue then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckDeath(szRule)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "dead" and target then
		if target.nMoveState == MOVE_STATE.ON_DEATH then
			return true
		end
	elseif szRule == "nodead" and target then
		if target.nMoveState ~= MOVE_STATE.ON_DEATH then
			return true
		end
    end

	return false
end

function Martin_Macro.CheckAlliance(szRUle)
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "ally" and target then
		if IsAlly(player.dwID,target.dwID) then
			return true
		end
	elseif szRule == "enemy" and target then
		if IsEnemy(player.dwID,target.dwID) then
			return true
		end
	elseif szRule == "neutral" and target then
		if IsNeutrality(player.dwID,target.dwID) then
			return true
		end
	end

	return false
end

--������ͨ״̬��
function Martin_Macro.CheckStatus(szRule,szStatus)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	local dummy
	local bcheckstate

	if szRule == "status" then
		dummy = player
		bcheckstate = true
	elseif szRule == "nostatus" then
		dummy = player
		bcheckstate = false
	elseif szRule == "tstatus" and target then
		dummy = target
		bcheckstate = true
	elseif szRule == "tnostatus" and target then
		dummy = target
		bcheckstate = false
	end
    
	if bcheckstate then
		if szStatus == g_tStrings.tPlayerMoveState[dummy.nMoveState] then
			return true
		end
	else
		if szStatus ~= g_tStrings.tPlayerMoveState[dummy.nMoveState] then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckForce(szRUle,szForceName)

	local player = GetClientPlayer()
	local ttype, tid = player.GetTarget()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "tforce" and target and ttype == 4 then
		if g_tStrings.tForceTitle[target.dwForceID] == szForceName then
			return true
		end
	elseif szRule == "tnoforce" and target and ttype == 4 then
		if g_tStrings.tForceTitle[target.dwForceID] ~= szForceName then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckKungfuMount(szRule,szKungfuName)

	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())

	if szRule == "mount" then
		if player.GetKungfuMount().szSkillName == szKungfuName then
			return true
		end
	elseif szRule == "nomount" then
		if player.GetKungfuMount().szSkillName ~= szKungfuName then
			return true
		end
	elseif szRule == "tmount" and target and ttype == 4  and target then
		if target.GetKungfuMount().szSkillName == szKungfuName then
			return true
		end
	elseif szRule == "tnomount" and target and ttype == 4  and target then
		if target.GetKungfuMount().szSkillName ~= szKungfuName then
			return true
		end
	end

	return false

end

function Martin_Macro.CheckState(szRule, sParam)
    if szRule == "state" then
        if sParam == "�޼���" then
            local szOption = "nobuff:�޺�����|��|����|����ɽ|��ɽ��|����|̫��|����|Ȫ����|������|תǬ��|��صͰ�|Ц���|̰ħ��"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "������" then
            local szOption = "nobuff:�޺�����|��|����|����ɽ|��ɽ��|����|̫��|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "������" then
            local szOption = "status:������|ѣ��|����|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "�ɿ���" then
            local szOption = "nobuff:��Ȫ����|��Ծ��Ԩ|��ɽ��|����|����|�۹�|��̫��|ǧ��׹|תǬ��|��¥��Ӱ|�Ƴ��|Х��|����֮��|������Ⱥ|�����׼�|������|�̵��׼�|����|����|���|��Ȼ|̰ħ��|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "�Ǳ���" then
            local szOption = "nostatus:������|ѣ��|����|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end

    elseif szRule == "tstate" then
        if sParam == "�ɿ���" then
            local szOption = "tnobuff:��Ȫ����|��Ծ��Ԩ|��ɽ��|����|����|�۹�|��̫��|ǧ��׹|תǬ��|��¥��Ӱ|�Ƴ��|Х��|����֮��|������Ⱥ|�����׼�|������|�̵��׼�|����|����|���|��Ȼ|̰ħ��|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "�Ǳ���" then
            local szOption = "tnostatus:������|ѣ��|����|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "������" then
            local szOption = "tnobuff:�޺�����|��|����|����ɽ|��ɽ��|����|̫��|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "������" then
            local szOption = "tstatus:������|ѣ��|����|����"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "�޼���" then
            local szOption = "tnobuff:�޺�����|��|����|����ɽ|��ɽ��|����|̫��|����|Ȫ����|������|תǬ��|��صͰ�|Ц���|̰ħ��"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        elseif sParam == "�м���" then
            local szOption = "tbuff:�޺�����|��|����|����ɽ|��ɽ��|����|̫��|����|Ȫ����|������|תǬ��|��صͰ�|Ц���|̰ħ��"
            return Martin_Macro.CalculateMacroConditionResult(szOption)
        end
    end
end

function Martin_Macro.CheckMacroCondition(szRule, szKeyName)
    if szKeyName ~= "" then
        if szKeyName:find("distance") ~= nil or szKeyName:find("Distance") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"=", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" or ch == "<=" or ch == ">=" then
                    tStackDataTable[1] = ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- ���һ���ַ�, ����Ҫ������һ��
                        tStackDataTable[2] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.MyGetDistance(tStackDataTable[1], tStackDataTable[2])

        elseif szKeyName:find("life") ~= nil or szKeyName:find("mana") ~= nil or szKeyName:find("power") ~= nil or szKeyName:find("rage") ~= nil or szKeyName:find("dance") ~= nil or szKeyName:find("energy") ~= nil or szKeyName:find("solar") ~= nil or szKeyName:find("luna") ~= nil or szKeyName:find("flypower") ~= nil then
            local szCurrentWord = ""
            local tStackDataTable = {"", "=", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" or ch == "<=" or ch == ">=" then
                    tStackDataTable[1] = szCurrentWord
                    tStackDataTable[2] = ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- ���һ���ַ�, ����Ҫ������һ��
                        tStackDataTable[3] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.CheckCharacterPointValue(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])

        elseif szRule:find("bufftime") ~= nil then      
            local szCurrentWord = ""
            local tStackDataTable = {szRule, "", "=", ""}
            for i = 1, #szKeyName do
                local ch = szKeyName:sub(i, i)
                if ch == ">" or ch == "=" or ch == "<" or ch == "<=" or ch == ">=" then
                    tStackDataTable[2] = szCurrentWord
                    tStackDataTable[3] = ch
                    szCurrentWord = ""
                else
                    szCurrentWord = szCurrentWord .. ch
                    if #szKeyName == i then		-- ���һ���ַ�, ����Ҫ������һ��
                        tStackDataTable[4] = szCurrentWord
                    end
                end  
            end
            return Martin_Macro.CheckBuffTime(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3], tStackDataTable[4])

        elseif szRule:find("buff") ~= nil then
                return Martin_Macro.CheckBuff(szRule,szKeyName)

        elseif szRule:find("status") ~= nil then
                return Martin_Macro.CheckStatus(szRule,szKeyName)

        elseif szKeyName:find("ally") ~= nil or szRule:find("enemy") ~= nil or szRule:find("neutral") ~= nil then
                return Martin_Macro.CheckAlliance(szKeyName)

        elseif szKeyName:find("horse") ~= nil then
                return Martin_Macro.CheckHorse(szKeyName)

        elseif szKeyName:find("fight") ~= nil then
                return Martin_Macro.CheckFight(szKeyName)

        elseif szKeyName:find("dead") ~= nil then
                return Martin_Macro.CheckDeath(szKeyName)

        elseif szRule:find("prepare") ~= nil then
                return Martin_Macro.CheckSkillPrepare(szRule,szKeyName)

        elseif szRule:find("cast") ~= nil then
                return Martin_Macro.CheckCast(szRule,szKeyName)

        elseif szRule:find("state") ~= nil then
                return Martin_Macro.CheckState(szRule,szKeyName)

        elseif szRule:find("cdtime") ~= nil then
                local szCurrentWord = ""
                local tStackDataTable = {"", "=", 0}
                for i = 1, #szKeyName do
                    local ch = szKeyName:sub(i, i)
                    if ch == ">" or ch == "=" or ch == "<" or ch == "<=" or ch == ">=" then
                        tStackDataTable[1] = szCurrentWord
                        tStackDataTable[2] = ch
                        szCurrentWord = ""
                    else
                        szCurrentWord = szCurrentWord .. ch
                        if #szKeyName == i then		-- ���һ���ַ�, ����Ҫ������һ��
                            tStackDataTable[3] = tonumber(szCurrentWord)
                        end
                    end
                end
                return Martin_Macro.CheckSkillCDTime(tStackDataTable[1], tStackDataTable[2], tStackDataTable[3])

        elseif szRule:find("cd") ~= nil or szRule:find("Cd") or szRule:find("CD") or szRule:find("cD") then
                return Martin_Macro.CheckSkillCD(szRule,szKeyName)

        elseif szRule:find("mount") ~= nil then
                return Martin_Macro.CheckKungfuMount(szRule,szKeyName)

        elseif szRule:find("force") ~= nil then
                return Martin_Macro.CheckForce(szRule,szKeyName)

        end
    end

	return true
end

function Martin_Macro.CalculateMacroConditionResult(szMsg)
	local szCurrentWord = ""

	local nCurrentStackLevel = 1;						    -- ��������еĵ�ǰջ��
	local tStackDataTable = {[1] = {true, "+",""}}			-- �������治ͬջ���µ���ʱ���, ÿ��ջ��������ֵ, �ֱ��� {��ǰֵ, ��һ�μ������}

	local CalculateStackResult = function(bResult)
		if tStackDataTable[nCurrentStackLevel][2] == "+" then
			tStackDataTable[nCurrentStackLevel][1] = tStackDataTable[nCurrentStackLevel][1] and bResult
		elseif tStackDataTable[nCurrentStackLevel][2] == "|" then
			tStackDataTable[nCurrentStackLevel][1] = tStackDataTable[nCurrentStackLevel][1] or bResult
        else
            tStackDataTable[nCurrentStackLevel][1] = bResult
		end
		tStackDataTable[nCurrentStackLevel][2] = ""
		szCurrentWord = ""
		return tStackDataTable[nCurrentStackLevel][1]
	end

	for i = 1, #szMsg do
		local ch = szMsg:sub(i, i)
		local szRule = tStackDataTable[nCurrentStackLevel][3]
		---- �õ�һ���µ�ջ��, ���ʼ�����ջ����Ĭ������
		if ch == "(" then
			nCurrentStackLevel = nCurrentStackLevel + 1
			tStackDataTable[nCurrentStackLevel] = {true, "+", ""}
			szCurrentWord = ""

		-- ջ���½�, �����½��������, ���Ҽ���ԭ��ջ���ϵĽ��
		elseif ch == ")" then
			local bResult = CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			nCurrentStackLevel = nCurrentStackLevel - 1
			CalculateStackResult(bResult)

		-- ���һ���µ� Rule, ֮��ļ��㶼�������RuleΪ����
		elseif ch == ":" then
			szRule = szCurrentWord
            tStackDataTable[nCurrentStackLevel][3] = szRule
			szCurrentWord = ""

		-- ����һ�� And ���,����֮ǰ�Ľ��, ���Ұѷ��ż�¼��ջ������
		elseif ch == "+" then
			CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			tStackDataTable[nCurrentStackLevel][2] = "+"

		-- ����һ�� Or ���,����֮ǰ�Ľ��, ���Ұѷ��ż�¼��ջ������
		elseif ch == "|" then
			CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			tStackDataTable[nCurrentStackLevel][2] = "|"

        -- ����һ�� , ���,����֮ǰ�Ľ��, Ϊ����ֱ�ӷ���
		elseif ch == "," or ch == "��" then
            CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
            szRule = szCurrentWord
            tStackDataTable[nCurrentStackLevel][3] = szRule
			if tStackDataTable[1][1] == false then
                return tStackDataTable[1][1]
            end

        -- ����һ�� ; ���,����֮ǰ�Ľ��
		elseif ch == ";" or ch == "��" then
            CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
            szRule = szCurrentWord
            tStackDataTable[nCurrentStackLevel][2] = "|"
            tStackDataTable[nCurrentStackLevel][3] = szRule

		-- �����������֯��ǰ��, ������ֵ������Ǿͻ�Ҫ������һ��
		else
			szCurrentWord = szCurrentWord .. ch
			if #szMsg == i then		-- ���һ���ַ�, ����Ҫ������һ��
				CalculateStackResult(Martin_Macro.CheckMacroCondition(szRule, szCurrentWord))
			end
		end
	end

	if nCurrentStackLevel ~= 1 then
		--Output("ջ������!")
		return false
	end
    
	return tStackDataTable[1][1]
end

--��ָ���ĺ�ָ��ת����Luaָ��
function Martin_Macro.Str_To_Lua(strCodes)
    local szRule, szCondition, szSkillName = "", "", ""

    szRule = strCodes:gsub("%b[]",""):gsub("%s*",""):gsub("%/",""):gsub("%A+","")

    for k in strCodes:gmatch("%b[]") do
        szCondition = k:sub(2,-2)
	end

    szSkillName  = strCodes:gsub("%b[]",""):gsub("%s*",""):gsub("%/",""):gsub("%a+","")

    return szRule, szCondition, szSkillName
end

--Martin_Macro.hfile = assert(io.open("C:\\Windows\\testRead.txt", 'r'))

--function Martin_Macro.SetFile()
    --Martin_Macro.hfile:seek("set")
--end

--RegisterEvent("DO_SKILL_CAST",  function()
  --local szText = Table_GetSkillName(arg1, arg2)
  --if szText == "���Ҽ���" and arg0 == GetClientPlayer().dwID then
		--Output(111)
  --end
--end)

function Martin_Macro.Run()
	collectgarbage("collect")

    for szMsg in io.lines("C:\\Windows\\testRead.txt") do
        --if GetClientPlayer().GetOTActionState() == 2 and Martin_Macro.bChannel then
            --return
        --end

        local szRule, szCondition, szSkillName = Martin_Macro.Str_To_Lua(szMsg)

        if szRule == "cast" then
             if Martin_Macro.CalculateMacroConditionResult(szCondition) then           
                local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                if nSkillID ~= 2603 then
                    OnUseSkill(nSkillID, nSkillLv)
                end
            end 
        --elseif szRule == "config" then
            --if szCondition == "��������" then
                --Martin_Macro.bChannel = true
            --elseif szCondition == "����������" then
                --Martin_Macro.bChannel = false
            --end          
        end

    end

        --if GetClientPlayer().GetOTActionState() == 2 and Martin_Macro.bChannel then
            --Martin_Macro.hfile:seek("set")
            --return
        --end

        --local szCode = Martin_Macro.hfile:read("*line")
        --Output(szCode)

        --if szCode == nil then
            --Martin_Macro.hfile:seek("set")
            --Martin_Macro.Run()
        --else
            --local szRule, szCondition, szSkillName = Martin_Macro.Str_To_Lua(szCode)
            
            --if szRule == "cast" then
                 --if Martin_Macro.CalculateMacroConditionResult(szCondition) then           
                    --local nSkillID, nSkillLv = Martin_Macro.GetSkillID(szSkillName)
                    --if nSkillID ~= 2603 then
                        --OnUseSkill(nSkillID, nSkillLv)
                    --end
                --end

            --elseif szRule == "config" then
                --if szCondition == "��������" then
                    --Martin_Macro.bChannel = true
                    --Martin_Macro.Run()

                --elseif szCondition == "����������" then
                    --Martin_Macro.bChannel = false
                    --Martin_Macro.Run()
                --end          
            --end
        --end
end

OutputMessage("MSG_SYS", "======���سɹ�======".."\n")


--function Martin_Macro.OnFrameBreathe()

    --if Martin_Macro.nStepper % 5 == 0 then
        --Martin_Macro.Run()
    --end

    --Martin_Macro.nStepper = Martin_Macro.nStepper + 1

--end

--function Martin_Macro.OpenWindow()
    --local frame = Station.Lookup("Lowest/Martin_Macro") --���崰��Ϊframe
    --if not frame then --���û�з��ִ��壬��򿪴���
        --Martin_Macro.hfile = assert(io.open("C:\\Windows\\testRead.txt", 'r'))
        --Martin_Macro.nStepper = 0
        --Martin_Macro.OnFrameBreathe()
        --Wnd.OpenWindow("C:\\Windows\\Martin_Macro.ini", "Martin_Macro")
    --end
    --frame:Show() --��������ʾ����
--end

--function Martin_Macro.CloseWindow()
    --local frame = Station.Lookup("Lowest/Martin_Macro") --���崰��Ϊframe
    --if frame then --���û�з��ִ��壬��򿪴���
        --Martin_Macro.hfile:close()
        --Wnd.CloseWindow(frame)
    --end
--end

collectgarbage("collect")