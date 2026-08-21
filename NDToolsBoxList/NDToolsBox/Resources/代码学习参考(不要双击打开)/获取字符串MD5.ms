FN GetMD5Hash strText =
(
	Encoding = dotnetclass "System.Text.Encoding"
	md5 = dotnetobject "System.Security.Cryptography.MD5CryptoServiceProvider"
	result = md5.ComputeHash(Encoding.Default.GetBytes(strText))
	
	MD5Str = ""
	for v in result do MD5Str += (dotnetobject "System.int32" v ).toString "X2"
	
	MD5Str
)

GetMD5Hash "DotNet For MXS 技术交流 364518591"
