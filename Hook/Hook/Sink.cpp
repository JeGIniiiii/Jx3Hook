#include "Sink.h"
#include "Release\allpurauthentic.tlh"

CSink::CSink(void)
{
	m_refCount = 1;
}

CSink::~CSink(void)
{
}

STDMETHODIMP CSink::QueryInterface(const struct _GUID &iid, void** ppv)
{
    if (iid == IID_IUnknown)
    {
        m_refCount++;
        *ppv = (void *)this;
        return S_OK;
    }

    if (iid == DIID__ICurrencyAuthEvents)
    {
        m_refCount++;
        *ppv = (void *)this;
        return S_OK;
    }

    return E_NOINTERFACE;
}

ULONG __stdcall CSink::AddRef(void)
{
    m_refCount++;
    return m_refCount;
}

ULONG __stdcall CSink::Release(void)
{
	if(--m_refCount <= 0) 
	{
		return 0;
	}
 
	return m_refCount;
}

STDMETHODIMP CSink::GetTypeInfoCount(unsigned int *)
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::GetTypeInfo(unsigned int, unsigned long, ITypeInfo** )
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::GetIDsOfNames(const IID&, LPOLESTR*, UINT, LCID, DISPID*)
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::Invoke(long dispID, const _GUID&, unsigned long, unsigned short,
tagDISPPARAMS * pParams, tagVARIANT*, tagEXCEPINFO*, unsigned int*)
{
	OnEvent(dispID, pParams);
	return S_OK;
}

extern HWND g_hDlg;
#define IDD_UPDATA      5001
#define IDD_NOTICES     5002

void CSink::OnEvent(long dispID, tagDISPPARAMS* pParams)
{
    //�յ���֤����������¼�
    switch(dispID) {
    case 1: //���Զ��������ص�tempĿ¼, ����Update���滻���²�����
        MessageBox(NULL, TEXT("�����и���, ���ȷ����ʼ����\r\n��ϸ��Ϣ�뿴�·�����"), TEXT("��ʾ"), MB_OK);
        //pAuth->Update();    //Update �Ĺ��� �˳�������->�滻�����ص��ļ�->����������
        SendMessage(g_hDlg, WM_COMMAND, (WPARAM)IDD_UPDATA, NULL);
        break;

    case 2:	//��Ϊ��Ч״̬, 30��������˳�������
        MessageBox(NULL, TEXT("�˿���ʧЧ, 30����Զ��˳�\r\n����ϵ����ͷ���ֵ!"), TEXT("��ʾ"), MB_OK);
        break;

    case 3:	//�յ�����
        //::MessageBox(NULL, L"����!", L"����", MB_OK);
        SendMessage(g_hDlg, WM_COMMAND, (WPARAM)IDD_NOTICES, (LPARAM)pParams->rgvarg[0].bstrVal);
        break;
    }
}