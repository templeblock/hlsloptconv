

#pragma once
#include "compiler.hpp"

#include <unordered_map>


namespace HOC {


struct PreprocMacro
{
	Array<String> args;
	Array<SLToken> tokens;
	bool isFunc = false;
};
typedef std::unordered_map<String, PreprocMacro> PreprocMacroMap;

struct CurFunctionInfo
{
	ASTFunction* func = nullptr;
	VarDecl* scopeVars = nullptr;
};

struct Parser
{
	Parser(Diagnostic& d, HOC_Config* cfg) :
		diag(d),
		config(cfg),
		entryPointName(cfg->entryPoint)
	{
		ast.stage = (ShaderStage) cfg->stage;
		// for int bool token
		int32_t i01[2] = { 0, 1 };
		tokenData.append((char*)i01, sizeof(i01));
	}
	bool ParseCode(const char* text, const char** featureDefs);
	bool ParseTokens(const char* text, uint32_t source);
	bool PreprocessTokens(uint32_t source);

	SLToken RequestIntBoolToken(bool v);
	PreprocMacro RequestIntBoolMacro(bool v);
	int EvaluateConstantIntExpr(const Array<SLToken>& tokenArr, size_t startPos, size_t endPos);

	ASTType* ParseType(bool isFuncRet = false);
	ASTType* FindMemberType(ASTType* t, const String& name, uint32_t& memberID, int& swizzleComp);
	VoidExpr* CreateVoidExpr(); // for errors
	bool ParseSemantic(String& name, int& index);
	bool ParseArgList(ASTNode* out);
	int32_t CalcOverloadMatchFactor(ASTFunction* func, OpExpr* fcall, ASTType** equalArgs, bool err);
	void FindFunction(OpExpr* fcall, const String& name, const Location& loc);
	bool FindBestSplit(const Array<SLToken>& tokenArr, bool allowFunctions,
		size_t& curPos, size_t endPos, SLTokenType endTokenType, size_t& bestSplit, int& bestScore);
	Expr* ParseExpr(SLTokenType endTokenType = STT_Semicolon, size_t endPos = SIZE_MAX);
	ASTType* Promote(ASTType* a, ASTType* b);
	ASTType* FindCommonOpType(ASTType* rt0, ASTType* rt1);
	bool CanCast(ASTType* from, ASTType* to, bool castExplicitly);
	bool ParseExprList(ASTNode* out, SLTokenType endTokenType, size_t endPos);
	bool ParseInitList(ASTNode* out, int numItems, bool ctor);
	Stmt* ParseStatement();
	Stmt* ParseExprDeclStatement();
	bool ParseTypeArray(ASTType*& type);
	bool TryCastExprTo(Expr* expr, ASTType* tty, const char* what);
	int32_t ParseRegister(char ch, bool comp, int32_t limit);
	bool ParseDecl();

	const SLToken& T() const { return tokens[curToken]; }
	SLTokenType TT() const { return tokens[curToken].type; }

	bool FWD(Array<SLToken>& arr, size_t& i)
	{
		if (++i >= arr.size())
		{
			EmitError("unexpected end of file", false);
			diag.hasFatalErrors = true;
			return false;
		}
		return true;
	}
	bool FWD() { return FWD(tokens, curToken); }

	bool PPFWD(Array<SLToken>& arr, size_t& i)
	{
		FWD(arr, i);
		if (arr[i - 1].logicalLine != arr[i].logicalLine)
		{
			EmitError("unexpected end of preprocessor directive", arr[i - 1].loc);
			diag.hasFatalErrors = true;
			return false;
		}
		return true;
	}
	bool PPFWD() { return PPFWD(tokens, curToken); }

	bool EXPECT(const SLToken& t, SLTokenType tt)
	{
		if (t.type != tt)
		{
			EmitError(Twine("expected '") + TokenTypeToString(tt) + "', got '" + TokenToString(t) + "'");
			diag.hasFatalErrors = true;
			return false;
		}
		return true;
	}
	bool EXPECT(SLTokenType tt) { return EXPECT(T(), tt); }

	void EXPECTERR(const SLToken& t, const Twine& exp)
	{
		EmitError("expected " + exp + ", got '" + TokenToString(t) + "'");
		diag.hasFatalErrors = true;
	}
	void EXPECTERR(const Twine& exp) { EXPECTERR(T(), exp); }

	void EmitError(const Twine& msg, const Location& loc)
	{
		diag.EmitError(msg, loc);
	}
	void EmitError(const Twine& msg, bool withLoc = true)
	{
		diag.EmitError(msg, withLoc && curToken < tokens.size() ? T().loc : Location::BAD());
	}
	void EmitFatalError(const Twine& msg, const Location& loc)
	{
		diag.EmitError(msg, loc);
		diag.hasFatalErrors = true;
	}
	void EmitFatalError(const Twine& msg, bool withLoc = true)
	{
		diag.EmitError(msg, withLoc && curToken < tokens.size() ? T().loc : Location::BAD());
		diag.hasFatalErrors = true;
	}

#define SPLITSCORE_RTLASSOC 0x80
	int GetSplitScore(const Array<SLToken>& tokenArr,
		size_t pos, size_t start, bool allowFunctions);

	bool TokenStringDataEquals(const SLToken& t, const char* comp, size_t compsz) const;
	const char* TokenStringC(const SLToken& t) const;
	String TokenStringData(const SLToken& t) const;
	bool TokenBoolData(const SLToken& t) const;
	int32_t TokenInt32Data(const SLToken& t) const;
	double TokenFloatData(const SLToken& t) const;
	String TokenToString(const SLToken& t) const;

	bool TokenStringDataEquals(size_t i, const char* comp, size_t compsz) const;
	const char* TokenStringC(size_t i) const;
	String TokenStringData(size_t i) const;
	bool TokenBoolData(size_t i) const;
	int32_t TokenInt32Data(size_t i) const;
	double TokenFloatData(size_t i) const;
	String TokenToString(size_t i) const;

	bool TokenStringDataEquals(const char* comp, size_t compsz) const;
	const char* TokenStringC() const;
	String TokenStringData() const;
	bool TokenBoolData() const;
	int32_t TokenInt32Data() const;
	double TokenFloatData() const;
	String TokenToString() const;


	bool IsAttrib() const
	{
		auto tt = TT();
		return tt == STT_KW_In || tt == STT_KW_Out || tt == STT_KW_InOut;
	}


	Diagnostic& diag;
	HOC_Config* config;


	Array<String> filenames;
	Array<char> tokenData;
	Array<SLToken> tokens;
	PreprocMacroMap macros;
	size_t curToken = 0;
	bool isWriteCtx = false; // if current expression is part of a write

	CurFunctionInfo funcInfo;
	typedef Array<ASTFunction*> ASTFuncList;
	std::unordered_map<String, ASTFuncList> functions;
	String entryPointName;
	int entryPointCount = 0;

	AST ast;
};


} /* namespace HOC */

