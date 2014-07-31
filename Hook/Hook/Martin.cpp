#include "Martin.h"

///////////////////////////////////////////////////////////////
CMartin* CMartin::m_cInstance = NULL;
CMartin* martin = CMartin::GetInstance();

CMartin* CMartin::GetInstance()
{
    if (m_cInstance == NULL) {
        m_cInstance = new CMartin;
    }

    return m_cInstance;
}
///////////////////////////////////////////////////////////////

#pragma warning(push)
#pragma warning(disable : 4996)

int CMartin::MsgBox(const TCHAR* szCaption, const TCHAR* szFormat, ...)
{
    TCHAR szBuffer[1024];
    va_list pArgList;

    va_start(pArgList, szFormat);

    _vsntprintf(szBuffer, sizeof(szBuffer)/sizeof(TCHAR), szFormat, pArgList);

    va_end(pArgList);

    return MessageBox(NULL, szBuffer, szCaption, 0);
}


void CMartin::Debug(const TCHAR* szFormat, ...)
{
#ifdef _DEBUG
    TCHAR szBuffer[1024] = {TEXT("Debug:")};;
    va_list pArgList;

    va_start(pArgList, szFormat);

    _vsntprintf(szBuffer + _tcslen(szBuffer), 1024 - _tcslen(szBuffer)*2, szFormat, pArgList);

    va_end(pArgList);

    return OutputDebugString(szBuffer);
#endif
}
#pragma warning(pop)

//��ȡ�ڴ�
INT CMartin::ReadPtrByInt(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> ���ִ���!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(INT)) == 0) {
            return *(INT*)beginAddr;
        }
    } catch (...) {

    }
    //��ʾ������Ϣ
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

//��ȡ�ڴ�
BYTE CMartin::ReadPtrByByte(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> ���ִ���!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(BYTE)) == 0) {
            return *(BYTE*)beginAddr;
        }
    } catch (...) {

    }
    //��ʾ������Ϣ
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

//��ȡ�ڴ�
SHORT CMartin::ReadPtrByShort(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> ���ִ���!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(SHORT)) == 0) {
            return *(SHORT*)beginAddr;
        }
    } catch (...) {

    }
    //��ʾ������Ϣ
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

/************************************************************************
 *	��������: Martin  2014/07/19 23:59
 *	��������: FreeResFile
 *	��������: �ͷ���Դ��ָ��Ŀ¼
 *	�����б�: 
        dwResName : ��ԴID
        lpResType : ��Դ��ʶ��
        lpFilePathName : �ͷ�·��
 *	����˵��: �Ƿ�ɹ��ͷ�
************************************************************************/
bool CMartin::FreeResFile(DWORD dwResName, LPCWSTR lpResType, LPCWSTR lpFilePathName, DWORD nFlag)
{
    HMODULE hInstance = ::GetModuleHandle(NULL);//�õ�����ʵ�����          
    HRSRC hResID = ::FindResource(hInstance,MAKEINTRESOURCE(dwResName),lpResType);//������Դ      
    HGLOBAL hRes = ::LoadResource(hInstance,hResID);//������Դ       
    LPVOID pRes = ::LockResource(hRes);//������Դ                   
    if (pRes == NULL) {//����ʧ��       
        return FALSE;       
    }

    DWORD dwResSize = ::SizeofResource(hInstance,hResID);//�õ����ͷ���Դ�ļ���С       
    HANDLE hResFile = CreateFile(lpFilePathName,GENERIC_WRITE,0,NULL,nFlag,FILE_ATTRIBUTE_NORMAL,NULL);//�����ļ�                  
    if (INVALID_HANDLE_VALUE == hResFile) {           //TRACE("�����ļ�ʧ�ܣ�");          
        return FALSE;
    }

    DWORD dwWritten = 0;//д���ļ��Ĵ�С          
    WriteFile(hResFile,pRes,dwResSize,&dwWritten,NULL);//д���ļ�      
    CloseHandle(hResFile);//�ر��ļ����                   
    return (dwResSize == dwWritten);//��д���С�����ļ���С�����سɹ�������ʧ�� 
    //ʹ��ʾ��: FreeResFile(IDR_MYRES,"MYRES","D:\\1.exe");
}

HWND CMartin::GetGameHwnd()
{
    ProcessWindow procwin;  
    procwin.dwProcessId = GetCurrentProcessId();  
    procwin.hwndWindow = NULL;  

    // ����������  
    EnumWindows(EnumWindowCallBack, (LPARAM)&procwin);  

    return procwin.hwndWindow;
}

BOOL CALLBACK CMartin::EnumWindowCallBack(HWND hWnd, LPARAM lParam)  
{  
    ProcessWindow *pProcessWindow = (ProcessWindow *)lParam;  

    DWORD dwProcessId;  
    GetWindowThreadProcessId(hWnd, &dwProcessId);

    char szDlgName[20] = {0};
    GetWindowTextA(hWnd, szDlgName, sizeof(szDlgName));

    // �ж��Ƿ���ָ�����̵�������  
    if (pProcessWindow->dwProcessId == dwProcessId && IsWindowVisible(hWnd) && GetParent(hWnd) == NULL && strstr(szDlgName, "Dialog") == NULL)  
    {  
        pProcessWindow->hwndWindow = hWnd;  

        return FALSE;  
    }  

    return TRUE;  
}

BOOL CMartin::BreakLdrModuleLink(DWORD dwBaseAddr)
{
    PLDR_MODULE pLMFNode = NULL, pLNode = NULL ;
    PLDR_MODULE pLMHNode = NULL, pLMPNode = NULL;
    PLDR_MODULE pLMTNode = NULL;
    BOOL bSuccess = FALSE;

    //��ȡLDR_MODULE����ͷָ��
    __asm {
        pushad;
        pushfd;
        xor edx, edx;
        mov ebx, fs:[edx + 0x30];
        mov ecx, [ebx + 0x0C];
        lea edx, [ecx + 0x0C];
        mov ecx, [ecx + 0x0C];
        mov pLMHNode, edx;
        mov pLMFNode, ecx;
        popfd;
        popad;
    }

    //����Ŀ��
    PLDR_MODULE pLMNode = pLMFNode;
    pLMPNode = pLMHNode;
    do {
        //�Ƚ��Ƿ���Ŀ��ģ��
        if( (DWORD)pLMNode->BaseAddress == dwBaseAddr) {
            bSuccess = TRUE;
            break;
        }
        pLMPNode = pLMNode;
        pLMNode = (PLDR_MODULE)pLMNode->InLoadOrderModuleList.Flink;
    } while (pLMNode != pLMHNode);

    if( !bSuccess ) {
        OutputDebugString(TEXT("cannot find the dest module!"));
        return bSuccess; //δ�ҵ�Ŀ��ģ��
    }

    //�Ͽ�InLoadOrderModuleList��
    //�ؽ�Flink
    pLMTNode = (PLDR_MODULE)pLMNode->InLoadOrderModuleList.Flink;
    pLMPNode->InLoadOrderModuleList.Flink = (PLIST_ENTRY)pLMTNode;
    //�ؽ�Blink
    ((PLDR_MODULE)(pLMNode->InLoadOrderModuleList.Flink))->InLoadOrderModuleList.Blink  = 
        pLMNode->InLoadOrderModuleList.Blink;

    //�Ͽ�InMemoryOrderModuleList��
    //�ؽ�Flink
    pLMPNode->InMemoryOrderModuleList.Flink = 
        pLMNode->InMemoryOrderModuleList.Flink;
    //�ؽ�Blink
    pLMTNode = (PLML)(pLMNode->InMemoryOrderModuleList.Flink - sizeof(LIST_ENTRY));
    pLMTNode->InMemoryOrderModuleList.Blink =  
        pLMNode->InMemoryOrderModuleList.Blink;

    //�Ͽ�InInitializationOrderModuleList��
    //�ؽ�Flink
    pLMPNode->InInitializationOrderModuleList.Flink =  
        pLMNode->InInitializationOrderModuleList.Flink;

    //�ؽ�Blink
    pLMTNode = (PLML)(pLMNode->InInitializationOrderModuleList.Flink - 2*sizeof(LIST_ENTRY));
    pLMTNode->InInitializationOrderModuleList.Blink  = pLMNode->InInitializationOrderModuleList.Blink;
}

void CMartin::ModuleHide(HMODULE hInjectDll)
{
    DWORD dwOldProtect;
    VirtualProtect((LPVOID)hInjectDll,1024,PAGE_READWRITE, &dwOldProtect);
    PIMAGE_DOS_HEADER pDosHeader = (PIMAGE_DOS_HEADER) hInjectDll;

    //ĨȥMZ��־
    pDosHeader->e_magic = 0;

    //DOSͷ�������PEͷ
    PIMAGE_NT_HEADERS pNtHeader = (PIMAGE_NT_HEADERS)(pDosHeader+1);

    //ĨȥPE��־
    pNtHeader->Signature = 0;

    VirtualProtect((LPVOID)hInjectDll,1024,dwOldProtect, &dwOldProtect);

    //�Ͽ�LDR_MODULE
    BreakLdrModuleLink((DWORD)hInjectDll);
}