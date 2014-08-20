collectgarbage("collect")

Martin_Config = {}
Martin_Config.nStepper = 0
Martin_Config.nFram = 4
Martin_Config.bAuto = false
Martin_Config.bFace = true

RegisterCustomData("Martin_Config.nFram")
RegisterCustomData("Martin_Config.bFace")

function Martin_Config.OnFrameBreathe()

    if Martin_Config.bFace then
        Martin_Macro.FaceToTarget() --����Ŀ��
    end

    if Martin_Config.nStepper % Martin_Config.nFram == 0 then
        Martin_Macro.Run()
    end

    Martin_Config.nStepper = Martin_Config.nStepper + 1

    if Martin_Config.bAuto == false then
        local nKey, bShift, bCtrl, bAlt = Hotkey.Get("Martin")
        if Hotkey.IsKeyDown(nKey) == false then
            Martin_Config.CloseWindow()
        end
    end

end

function Martin_Config.OpenWindow()

    local frame = Station.Lookup("Lowest/Martin_Config") --���崰��Ϊframe
    if not frame then --���û�з��ִ��壬��򿪴���
        Wnd.OpenWindow("C:\\Windows\\config.ini", "Martin_Config")
    end
    frame:Show() --��������ʾ����

end

function Martin_Config.CloseWindow()

    local frame = Station.Lookup("Lowest/Martin_Config") --���崰��Ϊframe
    if frame then --�緢�ִ���, ��ر���
        Martin_Config.nStepper = 0
        Wnd.CloseWindow(frame)
    end

end

local meun = {szOption = "����һ��PVP",}
local firstlevelmenu = {szOption = "ִ��Ƶ��",}
table.insert(firstlevelmenu,{szOption = "16 ��/��",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 1 then return true end end,fnAction = function() Martin_Config.nFram = 1 OutputMessage("MSG_SYS", "======�޸�ִ��Ƶ��Ϊ:"..16/Martin_Config.nFram.."��/��, ����ͷ��˵����޸�======".."\n") end})
table.insert(firstlevelmenu,{szOption = "8   ��/��",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 2 then return true end end,fnAction = function() Martin_Config.nFram = 2 OutputMessage("MSG_SYS", "======�޸�ִ��Ƶ��Ϊ:"..16/Martin_Config.nFram.."��/��, ����ͷ��˵����޸�======".."\n") end})
table.insert(firstlevelmenu,{szOption = "4   ��/��",bMCheck = true,bCheck = true,bChecked = function() if Martin_Config.nFram == 4 then return true end end,fnAction = function() Martin_Config.nFram = 4 OutputMessage("MSG_SYS", "======�޸�ִ��Ƶ��Ϊ:"..16/Martin_Config.nFram.."��/��, ����ͷ��˵����޸�======".."\n") end})
table.insert(meun,firstlevelmenu)
local secondlevelmenu = {szOption = "�Զ�����",}
table.insert(secondlevelmenu,{szOption = "����",bMCheck = true,bCheck = true,bChecked = function() return Martin_Config.bFace end,fnAction = function() Martin_Config.bFace = not Martin_Config.bFace OutputMessage("MSG_SYS", "======�����Զ�����======".."\n") end})
table.insert(secondlevelmenu,{szOption = "�ر�",bMCheck = true,bCheck = true,bChecked = function() return not Martin_Config.bFace end,fnAction = function() Martin_Config.bFace = not Martin_Config.bFace OutputMessage("MSG_SYS", "======�ر��Զ�����======".."\n") end})
table.insert(meun,secondlevelmenu)
Player_AppendAddonMenu({meun})

local function MyRun()
    --Output(Hotkey.GetBinding(false))
    --Output(Hotkey.Get("Martin"))
    Martin_Config.OpenWindow()
    --Martin_Macro.Run()
end

local function MyOpen()
    OutputMessage("MSG_SYS", "======��ʼִ��======".."\n")
    Martin_Config.bAuto = true
    Martin_Config.OpenWindow()
end

local function MyClose()
    OutputMessage("MSG_SYS", "======����ִ��======".."\n")
    Martin_Config.bAuto = false
    Martin_Config.CloseWindow()
end

Hotkey.AddBinding("Martin","������","����һ��PVP",function() MyRun() end,nil)
Hotkey.AddBinding("Martin_Open","����","",function() MyOpen() end,nil)
Hotkey.AddBinding("Martin_Close","�ر�","",function() MyClose() end,nil)
--AppendCommand("����һ��PVP",MyRun())

function Martin_Config.Debug()
    collectgarbage("collect")
    Martin_Macro.GetFileCode()
    OutputMessage("MSG_SYS", "======���سɹ�======".."\n")
    OutputMessage("MSG_SYS", "======��ǰִ��Ƶ��:"..16/Martin_Config.nFram.."��/��, ����ͷ��˵����޸�======".."\n")
end

collectgarbage("collect")