#include "Hook.h"
#include "windows.h"
#include "resource.h"
#include "Martin.h"
#include <atlconv.h>
#include "Sink.h"


typedef int (*_SETHOOK)();
typedef int (*_SetStart)(int);
typedef int (*_SetFace)(BOOL);

void OnBnStart(HWND hDlg)
{
    int nErr = 10000;
    HMODULE hMod = LoadLibrary(_T("C:\\Windows\\Jx3Server.dll"));	//��ʾ����DLL 
    if (hMod) {
        _SETHOOK SetHook = (_SETHOOK)GetProcAddress(hMod, "SetHook");	//ע��ڶ�������ֻ����խ�ַ�
        SetHook();
    } else {
        nErr = GetLastError();
        martin->MsgBox(TEXT("��ʾ"), TEXT("ȱ�ٱر��ļ�, ����ϵ�ͷ�!!\r\n�������: %d"), nErr);
        return;
    }

    FreeLibrary(hMod);
}

void OnBnEdit(HWND hDlg)
{
    ShellExecute(hDlg, TEXT("open"), TEXT("C:\\Windows\\testRead.txt"), NULL, NULL, SW_SHOWNORMAL);
}

void OnCkFace(HWND hDlg)
{
    int nErr = 10000;
    HMODULE hMod = LoadLibrary(_T("C:\\Windows\\Jx3Server.dll"));	//��ʾ����DLL 
    if (hMod) {
        _SetFace SetFace = (_SetFace)GetProcAddress(hMod, "SetFace");	//ע��ڶ�������ֻ����խ�ַ�
        BOOL bIsFace = ::SendMessageA(::GetDlgItem(hDlg, IDC_CHECK_FACE), BM_GETCHECK, 0, 0);
        SetFace(bIsFace);
    } else {
        nErr = GetLastError();
        martin->MsgBox(TEXT("��ʾ"), TEXT("ȱ�ٱر��ļ�, ����ϵ�ͷ�!!\r\n�������: %d"), nErr);
        return;
    }

    FreeLibrary(hMod);
}

void OnBnSet(HWND hDlg)
{
    _SetStart SetStart;
    TCHAR strCode;
    ::GetWindowText(::GetDlgItem(hDlg, IDC_EDIT_START), &strCode, sizeof(TCHAR));

    USES_CONVERSION;
    char* szCode = W2A(&strCode);

    int nErr = 10000;
    HMODULE hMod = LoadLibrary(_T("C:\\Windows\\Jx3Server.dll")); //��ʾ����DLL
    if (hMod) {
        SetStart = (_SetStart)GetProcAddress(hMod, "SetStart");	//ע��ڶ�������ֻ����խ�ַ�
    } else {
        nErr = GetLastError();
        martin->MsgBox(TEXT("��ʾ"), TEXT("ȱ�ٱر��ļ�, ����ϵ�ͷ�!!\r\n�������: %d"), nErr);
        return;
    }

    if (IsWindowEnabled(::GetDlgItem(hDlg, IDC_EDIT_START))) {
        ::EnableWindow(::GetDlgItem(hDlg, IDC_EDIT_START), FALSE); //��ֹ
        ::SetWindowText(::GetDlgItem(hDlg, IDC_BUTTON_SET), TEXT("����"));
        SetStart(*szCode);
    } else {
        ::EnableWindow(::GetDlgItem(hDlg, IDC_EDIT_START), TRUE); //����
        ::SetWindowText(::GetDlgItem(hDlg, IDC_EDIT_START), TEXT(""));
        ::SetWindowText(::GetDlgItem(hDlg, IDC_BUTTON_SET), TEXT("����"));
        SetStart(VK_HOME);
    }

    FreeLibrary(hMod);
}

#define WM_TRAYICON_MSG (WM_USER+1100)

void TrayMyIcon(HWND hDlg, BOOL bAdd, BOOL bHideWnd = TRUE)
{
    NOTIFYICONDATA tnd;
    RtlZeroMemory(&tnd, sizeof(NOTIFYICONDATA));

    tnd.cbSize = sizeof(NOTIFYICONDATA);
    tnd.hWnd = hDlg; //�������ھ��
    tnd.uID = IDI_ICON; //ͼ��ID

    if ( bAdd == TRUE ) { //���������ͼ��
        tnd.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP; //���������
        tnd.uCallbackMessage = WM_TRAYICON_MSG; //�������ͼ��ʱ��������Ϣ
        tnd.hIcon = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_ICON)); //����ͼ��
        _tcscpy_s(tnd.szTip, sizeof(tnd.szTip), TEXT("���� v2.0 : ˫���򿪴���")); //��ʾ�ı�

        if (bHideWnd == TRUE) {
            ShowWindow(hDlg, SW_HIDE); //���ؽ��洰��
        }

        Shell_NotifyIcon(NIM_ADD, &tnd);
    } else { //ɾ��������ͼ��
        //ShowWindow(SW_SHOWNA); //��ʾ����(�ж���)
        //SetForegroundWindow(); //���ó�ǰ̨����
       Shell_NotifyIcon(NIM_DELETE, &tnd);
    }

}

static HWND g_LoginhDlg = NULL;
#define IDD_UPDATA      5001
#define IDD_NOTICES     5002
HWND g_hDlg = NULL;

BOOL CALLBACK DialogProc( HWND hwndDlg, UINT UMsg, WPARAM wParam, LPARAM lParam )
{
    static TCHAR szTices[1024];

    switch (UMsg) {
    case WM_INITDIALOG :
        g_hDlg = hwndDlg;
        ::SetWindowTextA(::GetDlgItem(hwndDlg, IDC_STATIC_TIME), pAuth->GetValidity());
        ::SetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_NOTICES), (char*)pAuth->GetBulletin());

        TrayMyIcon(hwndDlg, TRUE);
        ::SendMessage(hwndDlg, WM_SETICON, (WPARAM)TRUE, (LPARAM)LoadIcon(GetModuleHandle(NULL), (LPCTSTR)IDI_ICON));

        return TRUE;

    case WM_TRAYICON_MSG :
        switch(lParam)
        {
        case WM_LBUTTONDBLCLK:
            ShowWindow(hwndDlg, SW_RESTORE);
            SetForegroundWindow(hwndDlg);
            break;
        default:
            break;
        }

        return TRUE;

    case WM_COMMAND :
        switch (LOWORD (wParam)) {
        //case IDOK :
        case IDCANCEL :
            if (MessageBox(NULL, TEXT("���   ȷ��   ��С��������\r\n���   ȡ��   �˳�����"), TEXT("��ʾ"), MB_OKCANCEL) == IDOK) {
                TrayMyIcon(hwndDlg, TRUE);
            } else {
                TrayMyIcon(hwndDlg, FALSE);
                EndDialog (hwndDlg, 0);
                EndDialog (g_LoginhDlg, 0);   
            }
            
            return TRUE;

        case IDC_BUTTON_START :
            OnBnStart(hwndDlg);
            return TRUE;

        case IDC_BUTTON_EDIT :
            OnBnEdit(hwndDlg);
            return TRUE;

        case IDC_BUTTON_SET :
            OnBnSet(hwndDlg);
            return TRUE;

        case IDD_UPDATA :
            pAuth->Update();
            return TRUE;
        
        case IDD_NOTICES :
            ::SetWindowTextA(::GetDlgItem(g_hDlg, IDC_EDIT_NOTICES), _bstr_t((BSTR)lParam));
            return TRUE;

        case IDC_CHECK_FACE :
            OnCkFace(hwndDlg);
            return TRUE;
        }

    }
    return FALSE ;
}

static IConnectionPointContainer *  g_pConnectionPointContainer = NULL;
static IUnknown*                    g_pSinkUnk = NULL;		
static CSink*                       g_pSink = new CSink;
static DWORD						g_dwCookie = NULL;
static IConnectionPoint*			g_pConnectionPoint = NULL;

void OnBnLogin(HWND hwndDlg)
{
    char szUser[256];
    RtlZeroMemory(szUser, sizeof(szUser));
    char szPass[256] = {0};
    RtlZeroMemory(szPass, sizeof(szPass));

    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_USER), szUser, sizeof(szUser));
    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_PASS), szPass, sizeof(szPass));

    int nRet = pAuth->UserAuth(_bstr_t("{E9F403D4-F46A-4F47-824C-6FBCCBE60AAB}"), _bstr_t(szUser), _bstr_t(szPass));
    switch(nRet) {
    case -1:
        martin->MsgBox(TEXT("��ʾ"), TEXT("ע���벻����"));
        return;
    case -2:
        martin->MsgBox(TEXT("��ʾ"), TEXT("ע���뱻����"));
        return;
    case -3:
        martin->MsgBox(TEXT("��ʾ"), TEXT("�󶨻�������"));
        return;
    case -4:
        martin->MsgBox(TEXT("��ʾ"), TEXT("ע����������"));
        return;
    case -5:
        martin->MsgBox(TEXT("��ʾ"), TEXT("�ѹ���"));
        return;
    case -6:
        martin->MsgBox(TEXT("��ʾ"), TEXT("�û�����"));
        return;
    }

    ShowWindow(hwndDlg, FALSE);
    Sleep(200);

    DialogBox(GetModuleHandle(NULL), TEXT("Jx3Hook"), NULL, DialogProc);
}

void OnBnMoney(HWND hwndDlg)
{
    char szUser[256];
    RtlZeroMemory(szUser, sizeof(szUser));
    char szMoney[256];
    RtlZeroMemory(szMoney, sizeof(szMoney));

    SHORT iDays = 0;
    SHORT iPoint = 0;

    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_USER), szUser, sizeof(szUser));
    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_MONEY), szMoney, sizeof(szMoney));

    int nRet = pAuth->AddTime("{E9F403D4-F46A-4F47-824C-6FBCCBE60AAB}", szMoney, szUser, &iDays, &iPoint);
    if (nRet == 0) {
        martin->MsgBox(TEXT("��ʾ"), TEXT("��ֵ�ɹ�, ����: %d ��"), iDays);
    } else {
        martin->MsgBox(TEXT("��ʾ"), TEXT("��ֵʧ��, ����ϵ�ͷ�!"));
    }
}

void OnBnReg(HWND hwndDlg)
{
    char szUser[256];
    RtlZeroMemory(szUser, sizeof(szUser));
    char szPass[256];
    RtlZeroMemory(szPass, sizeof(szPass));

    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_USER), szUser, sizeof(szUser));
    ::GetWindowTextA(::GetDlgItem(hwndDlg, IDC_EDIT_PASS), szPass, sizeof(szPass));

    int nRet = pAuth->UserRegister("{E9F403D4-F46A-4F47-824C-6FBCCBE60AAB}", szUser, szPass, 0, 1, 0);

    if (nRet == 0) {
        martin->MsgBox(TEXT("��ʾ"), TEXT("ע��ɹ�, ���ֵ��ʹ��!!"));
    } else if (nRet == -8) {
        martin->MsgBox(TEXT("��ʾ"), TEXT("�û����ظ�"));
    } else {
        martin->MsgBox(TEXT("��ʾ"), TEXT("ע��ʧ��!!"));
    }
}

BOOL CALLBACK LoginProc( HWND hwndDlg, UINT UMsg, WPARAM wParam, LPARAM lParam )
{
    switch (UMsg) {
    case WM_INITDIALOG :
        g_LoginhDlg = hwndDlg;
        ::SendMessage(hwndDlg, WM_SETICON, (WPARAM)TRUE, (LPARAM)LoadIcon(GetModuleHandle(NULL), (LPCTSTR)IDI_ICON));       
        return TRUE;

    case WM_COMMAND :
        switch (LOWORD (wParam)) {
        //case IDOK :
        case IDCANCEL :
            EndDialog (hwndDlg, 0);
            return TRUE;

        case IDC_BUTTON_MONEY :
            OnBnMoney(hwndDlg);
            return TRUE;

        case IDC_BUTTON_LOGIN :
            OnBnLogin(hwndDlg);
            return TRUE;

        case IDC_BUTTON_REG :
            OnBnReg(hwndDlg);
            return TRUE;
        }

    }
    return FALSE ;
}

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
    HRESULT hr;

    CreateMutex(NULL, FALSE, _T("mutex_for_readcount"));//����һ��������

    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        // ������л�����
        martin->MsgBox(TEXT("��ʾ"), TEXT("�Ѵ�һ������!!"));
        return FALSE;
    }

    martin->FreeResFile(IDR_MYAUTH, TEXT("MYAUTH"), TEXT("C:\\Windows\\AllpurAuthentic.dll"), CREATE_ALWAYS);
    martin->FreeResFile(IDR_MYINI, TEXT("MYINI"), TEXT("C:\\Windows\\Martin_Macro.ini"), CREATE_ALWAYS);
    martin->FreeResFile(IDR_MYLUA, TEXT("MYLUA"), TEXT("C:\\Windows\\Martin_Macro.lua"), CREATE_ALWAYS);
    martin->FreeResFile(IDR_MYTXT, TEXT("MYTXT"), TEXT("C:\\Windows\\testRead.txt"), CREATE_NEW);
    martin->FreeResFile(IDR_MYDLL, TEXT("MYDLL"), TEXT("C:\\Windows\\Jx3Server.dll"), CREATE_ALWAYS);
    
    Sleep(200);

    //ע��V�����
    ::CoInitialize(NULL);
    WinExec("regsvr32.exe C:\\Windows\\AllpurAuthentic.dll /s", SW_SHOW);//ע�����ǵ�DM.DLL

    pAuth.CreateInstance(__uuidof(CurrencyAuth));
    pAuth->Initialize();//��֤�����ʼ��

    //�±ߴ������ڹҽ����ӵ�, ����COM������¼�
    hr = pAuth->QueryInterface(IID_IConnectionPointContainer, (void **)&g_pConnectionPointContainer);	        //����Ƿ�֧�����ӵ�
    OutputDebugString(TEXT("11111"));
    if (!SUCCEEDED(hr)) return 0;

    hr = g_pConnectionPointContainer->FindConnectionPoint(DIID__ICurrencyAuthEvents, &g_pConnectionPoint);		//������ӵ����
    OutputDebugString(TEXT("22222"));
    if (!SUCCEEDED(hr)) return 0;

    hr = g_pSink->QueryInterface(IID_IUnknown, (void **)&g_pSinkUnk);
    OutputDebugString(TEXT("33333"));
    if (!SUCCEEDED(hr)) return 0;

    hr = g_pConnectionPoint->Advise(g_pSinkUnk, &g_dwCookie);                                                   //connect to server����������1
    OutputDebugString(TEXT("44444"));
    if (!SUCCEEDED(hr)) return 0;
    ///////////////////////////////////////////////////////////////

    DialogBox(hInstance, TEXT("Login"), NULL, LoginProc);

    ///////////////////////////////////////////////////////////////
    g_pConnectionPointContainer->Release();
    g_pConnectionPoint->Unadvise(g_dwCookie);
    g_pConnectionPoint->Release();
    g_pSinkUnk->Release();
    delete g_pSink;
    ///////////////////////////////////////////////////////////////

    //������֤���
    pAuth.Release();
    ::CoUninitialize();

    remove("C:\\Windows\\Martin_Macro.ini");
    remove("C:\\Windows\\Martin_Macro.lua");
    remove("C:\\Windows\\Jx3Server.dll");
    remove("C:\\Windows\\AllpurAuthentic.dll");

    return 0;
}