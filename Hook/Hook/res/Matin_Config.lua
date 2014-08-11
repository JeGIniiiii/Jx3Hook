collectgarbage("collect")

Martin_Config = {}
Martin_Config.nStepper = 0
Martin_Config.nFram = 4

RegisterCustomData("Martin_Config.nFram")

function Martin_Config.OnFrameBreathe()

    if Martin_Config.nStepper % Martin_Config.nFram == 0 then
        Martin_Macro.Run()
    end

    Martin_Config.nStepper = Martin_Config.nStepper + 1

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
Player_AppendAddonMenu({meun})

function Martin_Config.Debug()
    collectgarbage("collect")
    Martin_Macro.GetFileCode()
    OutputMessage("MSG_SYS", "======���سɹ�======".."\n")
    OutputMessage("MSG_SYS", "======��ǰִ��Ƶ��:"..16/Martin_Config.nFram.."��/��, ����ͷ��˵����޸�======".."\n")
end

collectgarbage("collect")