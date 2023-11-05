// Watermark Disabler Proxy

#include "main.h"
// _countof
#define Length(a) (sizeof(a)/sizeof(a[0]))
// CLSID {ab0b37ec-56f6-4a0e-a8fd-7a8bf7c2da96} = explorerframe
#pragma comment(linker,"/export:DllGetClassObject=explorerframe.DllGetClassObject")
#pragma comment(linker,"/export:DllCanUnloadNow=explorerframe.DllCanUnloadNow")

static LPTSTR lpchNames[7];

// indexOf method of String class in jdk (is implemented by using BF)
int indexOf(LPCTSTR source, int sourceOffset, int sourceCount,
	LPCTSTR target, int targetOffset, int targetCount,
	int fromIndex)
{
	if (fromIndex >= sourceCount) {
		return (targetCount == 0 ? sourceCount : -1);
	}
	if (fromIndex < 0) {
		fromIndex = 0;
	}
	if (targetCount == 0) {
		return fromIndex;
	}

	TCHAR first = target[targetOffset];
	int max = sourceOffset + (sourceCount - targetCount);

	for (int i = sourceOffset + fromIndex; i <= max; i++) {
		/* Look for first character. */
		if (source[i] != first) {
			while (++i <= max && source[i] != first);
		}

		/* Found first character, now look at the rest of v2 */
		if (i <= max) {
			int j = i + 1;
			int end = j + targetCount - 1;
			for (int k = targetOffset + 1; j < end && source[j] ==
				target[k]; j++, k++);

				if (j == end) {
					/* Found whole string. */
					return i - sourceOffset;
				}
		}
	}
	return -1;
}

bool IsWatermarkText(LPCTSTR lptApiText)
{
	const TCHAR lptWs = '%';

	if (lptApiText == NULL)
		return false;
	if (lptApiText[0] == 0)
		return false;

	int lenApiText = _tcslen(lptApiText);
	for (int i = 0; i < Length(lpchNames); i++)
	{
		if (lpchNames[i] != NULL && lpchNames[i][0] != 0)
		{
			int stPoint = 0;
			int lenWaterText = _tcslen(lpchNames[i]);
			// fix %ws Build %ws
			if (i == 3)
				if (lpchNames[i][0] == lptWs && lenWaterText > 4)
				{
					stPoint = 4;
					while ((++stPoint < lenWaterText) && (lpchNames[i][stPoint] != lptWs));
					lenWaterText = stPoint - 4;
					stPoint = 4;
				}
			if (indexOf(lptApiText, 0, lenApiText, lpchNames[i], stPoint, lenWaterText, 0) >= 0)
				return true;
		}
	}
	return false;
}

// Proxy

INT WINAPI Proxy_LoadString(
	_In_opt_ HINSTANCE hInstance,
	_In_ UINT uID,
	_Out_ LPTSTR lpBuffer,
	_In_ int nBufferMax)
{
	if ((uID == 62000) || (uID == 62001))
		return 0;
	else
		return LoadString(hInstance, uID, lpBuffer, nBufferMax);
}

BOOL WINAPI Proxy_ExtTextOut(
	_In_ HDC hdc,
	_In_ int X,
	_In_ int Y,
	_In_ UINT fuOptions,
	_In_ const RECT *lprc,
	_In_ LPCTSTR lpString,
	_In_ UINT cbCount,
	_In_ const INT *lpDx)
{
	if (IsWatermarkText(lpString))
		return 1;
	else
		return ExtTextOutW(hdc, X, Y, fuOptions, lprc, lpString, cbCount, lpDx);
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD ul_reason_for_call,
	LPVOID lpReserved)
{
	if (ul_reason_for_call == DLL_PROCESS_ATTACH)
	{
		OutputDebugStringA("Loaded");
		HMODULE g_hShell32 = GetModuleHandle(_T("shell32.dll"));

		if (g_hShell32 != NULL)
		{
			BOOL bImportChanged;
			FARPROC pLoadString;

			pLoadString = GetProcAddress(GetModuleHandle(_T("api-ms-win-core-libraryloader-l1-2-0.dll")), "LoadStringW");
			if (pLoadString != NULL)
			{
				bImportChanged = ImportPatch::ChangeImportedAddress(g_hShell32, "api-ms-win-core-libraryloader-l1-2-0.dll", pLoadString, (FARPROC)Proxy_LoadString);
			}
			else 
			{
				pLoadString = GetProcAddress(GetModuleHandle(_T("api-ms-win-core-libraryloader-l1-1-1.dll")), "LoadStringW");
				if (pLoadString != NULL)
				{
					bImportChanged = ImportPatch::ChangeImportedAddress(g_hShell32, "api-ms-win-core-libraryloader-l1-1-1.dll", pLoadString, (FARPROC)Proxy_LoadString);
				}
			}
			FARPROC pExtTextOut = GetProcAddress(GetModuleHandle(_T("gdi32.dll")), "ExtTextOutW");
			if (pExtTextOut != NULL)
			{
				bImportChanged = ImportPatch::ChangeImportedAddress(g_hShell32, "gdi32.dll", pExtTextOut, (FARPROC)Proxy_ExtTextOut);
			}

			if (bImportChanged)
			{
				const LPTSTR lptBrand = _T("Windows ");
				const LPTSTR lptPr = _T("Build ");

				int iLpNamesSize[] = { 128, // Windows Branding
					64,		// Test Mode
					64,		// Safe Mode
					128,	// %ws Build %ws
					128,	// Evaluation copy.
					167,	// This copy of Windows is licensed for
					128 };	// SecureBoot isn't configured correctly

				for (BYTE i = 0; i < Length(lpchNames); i++)
					lpchNames[i] = (TCHAR*)malloc(iLpNamesSize[i] * sizeof(TCHAR));

				HMODULE h_Module = NULL;
				h_Module = LoadLibrary(_T("winbrand.dll"));
				if (h_Module != NULL)
				{
					typedef BOOL(WINAPI *BrandLoadStr_t)(LPTSTR, INT, LPTSTR, INT);
					BrandLoadStr_t BrandLoadStr = (BrandLoadStr_t)GetProcAddress(h_Module, "BrandingLoadString");
					int Result = BrandLoadStr(_T("Basebrd"), 12, lpchNames[0], iLpNamesSize[0]);
					if (Result == 0)
						lpchNames[0] = lptBrand;
					FreeLibrary(h_Module);
				}
				else lpchNames[0] = lptBrand;

				h_Module = GetModuleHandle(_T("shell32.dll"));
				if (h_Module != NULL)
				{
					UINT uiID[] = { 33088, 33089, 33108, 33109, 33111, 33117 };
					for (int i = 0; i < Length(uiID); i++)
					{
						int Result = LoadString(h_Module, uiID[i], lpchNames[i + 1], iLpNamesSize[i + 1]);
						if (Result == 0)
							lpchNames[i] = lptPr;
					}
					//FreeLibrary(h_Module);
				}
				else
					for (BYTE i = 1; i < Length(lpchNames); i++)
						lpchNames[i] = lptPr;
			}
		}
		DisableThreadLibraryCalls(hModule);
	}
	return 1;
}