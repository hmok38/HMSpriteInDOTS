# 本目录为package的示例开发目录,采用link的方式链接到Assets\HMFW\Samples~ 的示例发布目录,修改这里就相当于修改示例发布目录,避免修改后要同步过去

### window下link方式:

		在cmd中,注意不要在powershell中
		使用 "mklink/d 名字 目标文件夹" 链接目标目录
		使用 "mklink 名字 目标文件" 链接目标文件

### Linux和Mac:
		在终端使用 "ln -s 名字 目标文件夹" 命令链接