//
//
// Derived from Microsoft Sample IME by Jeremy '13,7,17
//
//
//#define DEBUG_PRINT

#include "Private.h"
#include "TfTextLayoutSink.h"
#include "DIME.h"
#include "GetTextExtentEditSession.h"

CTfTextLayoutSink::CTfTextLayoutSink(_In_ CDIME *pTextService)
{
	debugPrint(L"CTfTextLayoutSink::CTfTextLayoutSink() constructor");
    _pTextService = pTextService;
	if(_pTextService)
		_pTextService->AddRef();

    _pRangeComposition = nullptr;
    _pContextDocument = nullptr;
    _tfEditCookie = TF_INVALID_EDIT_COOKIE;

    _dwCookieTextLayoutSink = TF_INVALID_COOKIE;

    _refCount = 1;

    DllAddRef();
}

CTfTextLayoutSink::~CTfTextLayoutSink()
{
	debugPrint(L"CTfTextLayoutSink::~CTfTextLayoutSink() destructor");
    if (_pTextService)
    {
        _pTextService->Release();
    }

    DllRelease();
}

STDAPI CTfTextLayoutSink::QueryInterface(REFIID riid, _Outptr_ void **ppvObj)
{
    if (ppvObj == nullptr)
    {
        return E_INVALIDARG;
    }

    *ppvObj = nullptr;

    if (IsEqualIID(riid, IID_IUnknown) ||
        IsEqualIID(riid, IID_ITfTextLayoutSink))
    {
        *ppvObj = (ITfTextLayoutSink *)this;
    }

    if (*ppvObj)
    {
        AddRef();
        return S_OK;
    }

    return E_NOINTERFACE;
}

STDAPI_(ULONG) CTfTextLayoutSink::AddRef()
{
    return ++_refCount;
}

STDAPI_(ULONG) CTfTextLayoutSink::Release()
{
    LONG cr = --_refCount;

    assert(_refCount >= 0);

    if (_refCount == 0)
    {
        delete this;
    }

    return cr;
}

//+---------------------------------------------------------------------------
//
// ITfTextLayoutSink::OnLayoutChange
//
//----------------------------------------------------------------------------

STDAPI CTfTextLayoutSink::OnLayoutChange(_In_ ITfContext *pContext, TfLayoutCode lcode, _In_ ITfContextView *pContextView)
{
    // we're interested in only document context.
    if (pContext != _pContextDocument)
    {
        return S_OK;
    }

    switch (lcode)
    {
    case TF_LC_CHANGE:
        {
			debugPrint(L"CTfTextLayoutSink::OnLayoutChange() TF_LC_CHANGE");
            CGetTextExtentEditSession* pEditSession = nullptr;
            pEditSession = new (std::nothrow) CGetTextExtentEditSession(_pTextService, pContext, pContextView, _pRangeComposition, this);
            if (pEditSession && pContext && _pTextService)
            {
                HRESULT hr = S_OK;
                 pContext->RequestEditSession(_pTextService->_GetClientId(), pEditSession, TF_ES_SYNC | TF_ES_READ, &hr);

                pEditSession->Release();
            }
        }
        break;

    case TF_LC_DESTROY:
		debugPrint(L"CTfTextLayoutSink::OnLayoutChange() TF_LC_DESTROY");
        _LayoutDestroyNotification();
        break;

    }
    return S_OK;
}

HRESULT CTfTextLayoutSink::_StartLayout(_In_ ITfContext *pContextDocument, TfEditCookie ec, _In_ ITfRange *pRangeComposition)
{
	debugPrint(L"CTfTextLayoutSink::_StartLayout()\n");
	if(_pContextDocument != pContextDocument )
	{
		_pContextDocument = pContextDocument;
		if(_pContextDocument)
			_pContextDocument->AddRef();

		_pRangeComposition = pRangeComposition;
		if(_pRangeComposition) 
			_pRangeComposition->AddRef();

		_tfEditCookie = ec;

		return _AdviseTextLayoutSink();
	}
	else
		return S_OK;
}

VOID CTfTextLayoutSink::_EndLayout()
{
	debugPrint(L"CTfTextLayoutSink::_EndLayout()\n");
    if (_pRangeComposition)
    {
        _pRangeComposition->Release();
        _pRangeComposition = nullptr;
    }

    if(_pContextDocument)
    {
		_UnadviseTextLayoutSink();
		_pContextDocument->Release();
		_pContextDocument = nullptr;
	}
    
}

HRESULT CTfTextLayoutSink::_AdviseTextLayoutSink()
{
    HRESULT hr = S_OK;
    ITfSource* pSource = nullptr;
	if(_pContextDocument == nullptr) return S_OK;
    hr = _pContextDocument->QueryInterface(IID_ITfSource, (void **)&pSource);
    if (FAILED(hr) || pSource == nullptr)
    {
        return hr;
    }

    hr = pSource->AdviseSink(IID_ITfTextLayoutSink, (ITfTextLayoutSink *)this, &_dwCookieTextLayoutSink);
    if (FAILED(hr))
    {
        pSource->Release();
        return hr;
    }

    pSource->Release();

    return hr;
}

HRESULT CTfTextLayoutSink::_UnadviseTextLayoutSink()
{
    HRESULT hr = S_OK;
    ITfSource* pSource = nullptr;

    if (nullptr == _pContextDocument)
    {
        return E_FAIL;
    }

    hr = _pContextDocument->QueryInterface(IID_ITfSource, (void **)&pSource);
    if (FAILED(hr) && pSource == nullptr)
    {
        return hr;
    }

    hr = pSource->UnadviseSink(_dwCookieTextLayoutSink);
    if (FAILED(hr))
    {
        pSource->Release();
        return hr;
    }

    pSource->Release();

    return hr;
}

HRESULT CTfTextLayoutSink::_GetTextExt(_Inout_ RECT *lpRect)
{
	debugPrint (L"CTfTextLayoutSink::_GetTextExt()");

	if(lpRect == nullptr || _pContextDocument == nullptr) return E_ABORT;
    HRESULT hr = S_OK;
    BOOL isClipped = TRUE;
    ITfContextView* pContextView = nullptr;


    hr = _pContextDocument->GetActiveView(&pContextView);
    if (FAILED(hr))
    {
        return hr;
    }

    if (_pRangeComposition==nullptr || FAILED(hr = pContextView->GetTextExt(_tfEditCookie, _pRangeComposition, lpRect, &isClipped)))
    {
        return hr;
    }
	debugPrint (L"CTfTextLayoutSink::_GetTextExt(); top=%d, bottom=%d, left =%d, righ=%d",lpRect->top, lpRect->bottom, lpRect->left, lpRect->right);
    pContextView->Release();

    return S_OK;
}
