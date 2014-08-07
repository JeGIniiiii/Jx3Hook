// Jx3Server.cpp : ���� DLL Ӧ�ó���ĵ���������
//

#include "stdafx.h"
#include <process.h>
#include <windows.h>
#include "luainc.h"
#include <TLHELP32.H>
#include "Martin.h"

#pragma data_seg("MyJx3Sec") //--�ڿ�ʼ

int     g_start = 0x31;//Ҫ���������,ע��:Ҫ�����з���һ������,������������Ѿ���ʼ�� ��: int example = 100;
BOOL    g_bIsFace = TRUE;//Ҫ���������,ע��:Ҫ�����з���һ������,������������Ѿ���ʼ�� ��: int example = 100;
HHOOK   g_hHook = NULL;//Ҫ���������,ע��:Ҫ�����з���һ������,������������Ѿ���ʼ�� ��: int example = 100;

#pragma data_seg()	//--�ڽ���

//���ýڹ���:
#pragma comment(linker, "/section:MyJx3Sec,RWS")


DWORD GetLuaState()
{
    BYTE* modBaseAddr = NULL;

    //������Ľ����е�����ģ����һ������
    HANDLE hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,0);
    if (hModuleSnap == NULL)
    {
        return 0;
    }

    MODULEENTRY32 module32;
    //��ʹ������ṹ֮ǰ�����������Ĵ�С
    module32.dwSize = sizeof(module32);

    //����ģ����գ�������ʾÿ��ģ�����Ϣ
    BOOL bResult = Module32First(hModuleSnap,&module32);
    while(bResult)
    {
        //����õ�һ��ģ����ǽ��̵���ģ�飬Ҳ���ǽ��̶�Ӧ�Ŀ�ִ�г�������ʹ�ô˷���Ҳ���Եõ������ļ�·��
        if (wcsstr(module32.szModule, TEXT("KGUI.dll")) != NULL)
        {
            modBaseAddr = module32.modBaseAddr;
            modBaseAddr = modBaseAddr + 0x181E10;
            break;
        }

        ZeroMemory(&module32, 0);
        module32.dwSize = sizeof(MODULEENTRY32);

        bResult = Module32Next(hModuleSnap,&module32);
    }

    CloseHandle(hModuleSnap);

    DWORD L;
    _asm
    {
        mov esi, modBaseAddr;
        mov esi, [esi];
        lea ecx, [esi+0xD38];
        mov  ebx, [ecx+0x3C];
        mov L, ebx;
    }
    return L;
}

lua_State* L = NULL;

void OnButtionRun()
{
    try {
        luaL_dostring(L, "Martin_Macro.Run()");      
    } catch (...) {
    }
}

void OnButtionLoad()
{
    luaL_dofile(L, "C:\\Windows\\martin");
}

void OnButtionTms()
{
    try {
        luaL_dostring(L, "Martin_Macro.FaceToTarget()"); 	
    } catch (...) {
    }
}

BOOL        g_IsWork = TRUE;
BOOL        g_bIsFirst = TRUE;
HANDLE      g_h[2] = {NULL, NULL};
HMODULE     g_hModule = NULL;
HWND        g_hWgDlg = NULL;

//��ʼ������
void SetWork()
{
    try {
        luaL_dostring(L, "Martin_Macro.SetWork()"); 	
    } catch (...) {
    }

    if (g_bIsFirst == FALSE) {
        g_IsWork = FALSE;
        WaitForMultipleObjects(2, g_h, TRUE, INFINITE);
        CloseHandle(g_h[0]);
        CloseHandle(g_h[1]);
    }

    if (g_hWgDlg != NULL) {
        ::SendMessage(g_hWgDlg, WM_COMMAND, IDCANCEL, NULL);
    }
}

#define  WM_LOAD            WM_USER + 500
#define  WM_RUN             WM_USER + 501
#define  WM_TMS             WM_USER + 502
#define  WM_SETWORK         WM_USER + 503

BOOL CALLBACK MsgProc( HWND hwndDlg, UINT UMsg, WPARAM wParam, LPARAM lParam )
{
    switch (UMsg) {
    case WM_INITDIALOG :
        L = (lua_State*)GetLuaState();
        return TRUE;

    case WM_LOAD:
        OnButtionLoad();
        return TRUE;

    case WM_RUN:
        OnButtionRun();
        return TRUE;

    case WM_TMS:
        OnButtionTms();
        return TRUE;

    case WM_SETWORK:
        SetWork();
        return TRUE;

    case WM_NCDESTROY:
        if (g_hHook != NULL) {
            UnhookWindowsHookEx(g_hHook);
            g_hHook = NULL;
        }

        if (g_hModule != NULL) {
            ::CloseHandle(::CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)FreeLibrary, g_hModule, 0, NULL));
        }
        return TRUE;

    case WM_COMMAND :
        switch (LOWORD (wParam)) {
        case IDCANCEL:
            DestroyWindow(hwndDlg);
            g_hWgDlg = NULL;
            return TRUE;
        }
    }
    return FALSE ;
}

unsigned int __stdcall ScriptRun(PVOID pM)  
{
    while(g_IsWork) {
        if (GetKeyState(g_start) < 0) {    //����1��״̬
            if (g_hWgDlg != NULL) {
                ::SendMessage(g_hWgDlg, WM_RUN, NULL, NULL);
                Sleep(70);
            }
        }
        Sleep(30);
    }

    return  0;
}

unsigned int __stdcall TuoMasi(PVOID pM)  
{
    while(g_IsWork) {
        if (g_bIsFace) {
            if (GetKeyState(g_start) < 0) {    //����Q��״̬
                if (g_hWgDlg != NULL) {
                    ::SendMessage(g_hWgDlg, WM_TMS, NULL, NULL);
                }
            }
        }
        Sleep(30);
    }

    return  0;
}

LRESULT CALLBACK GameProc(
    int code,       // hook code
    WPARAM wParam,  // virtual-key code == VK_HOME
    LPARAM lParam   // keystroke-message information
    )
{
    if (g_bIsFirst) {
        if (GetKeyState(VK_HOME) < 0) {    //����HOME��	
            if (g_hWgDlg == NULL) {
                g_hWgDlg = CreateDialog(g_hModule, TEXT("MSG"), NULL, MsgProc);
                g_h[0] = (HANDLE)_beginthreadex(NULL, 0, ScriptRun, NULL, 0, NULL);
                g_h[1] = (HANDLE)_beginthreadex(NULL, 0, TuoMasi, NULL, 0, NULL);
                g_bIsFirst = FALSE;
            }
        }
    }

    if (GetKeyState(VK_HOME) < 0) {    //����HOME��	
        if (g_hWgDlg != NULL) {
            ::SendMessage(g_hWgDlg, WM_LOAD, NULL, NULL);
        }
    }

    return CallNextHookEx(
        0,      // handle to current hook
        code,      // hook code passed to hook procedure
        wParam,  // value passed to hook procedure
        lParam   // value passed to hook procedure
        );

}

extern "C" __declspec(dllexport) void SetHook();
extern "C" __declspec(dllexport) void SetStart(int);
extern "C" __declspec(dllexport) void SetFace(BOOL);

//��װ����
void SetHook()
{
    if (g_hHook == NULL) {
        //��ȡ��Ϸ���߳�ID��
        HWND h = ::FindWindow(NULL,L"������Ե�������PakV3");
        if (h == NULL) {
            martin->MsgBox(TEXT("��ʾ"), TEXT("���ȴ���Ϸ!!"));
            return;
        }

        DWORD pid = NULL;
        DWORD tid = GetWindowThreadProcessId(h, &pid);

        g_hHook = SetWindowsHookEx(
            WH_KEYBOARD,        // hook type
            GameProc,     // hook procedure
            GetModuleHandle(TEXT("dll.dll")),    // handle to application instance
            tid	 // thread identifier
            );
    } else {
        martin->MsgBox(TEXT("��ʾ"), TEXT("�Ѿ���ʼа��, �벻Ҫ�ظ���ʼ."));
    }
}

//���ð���
void SetStart(int startCode)
{
    g_start = startCode;
}

//�����Ƿ�������
void SetFace(BOOL bIsFace)
{
    g_bIsFace = bIsFace;
}