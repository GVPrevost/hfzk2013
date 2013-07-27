unit Cache_;

interface

uses
  Classes, Sysutils, Windows, Graphics, Global;

type
  TCache = class(TPersistent)
  private
    FID: string;
    FPicturePath: string;
    FSNSContextPath: string;
    FAccount_Type: TAccount_Type;
    FAccount_Name: string;

    procedure CheckPath;
    procedure InitPath;
    procedure SetID(const Value: string);
    procedure SetAccount_Name(const Value: string);
    procedure SetAccount_Type(const Value: TAccount_Type);
  published

  public
    property ID: string read FID write SetID;
    property Account_Type: TAccount_Type read FAccount_Type write SetAccount_Type;
    property Account_Name: string read FAccount_Name write SetAccount_Name;
    property PicturePath: string read FPicturePath;
    property SNSContextPath: string read FSNSContextPath;

    function SetPicture(fn: string;pic: TGraphic): boolean;
    function GetPicture(fn: string): TGraphic;
  end;

var
  Cache: TCache;

implementation

procedure Init;
begin
  Cache := TCache.Create;
end;

procedure Uninit;
begin
  Cache.Free;
end;

{ TCache }

procedure TCache.CheckPath;
begin
  if (FPicturePath = '') or (FSNSContextPath = '') then
    Abort;
end;

function TCache.GetPicture(fn: string): TGraphic;
var
  fs: TMemoryStream;
  fname: string;
begin
  result := nil;
  CheckPath;

  fname := Format('%s\%s', [FPicturePath, fn]);
  fs := TMemoryStream.Create();
  try
    fs.LoadFromFile(fname);
    result := LoadPicture(fs);
  except
    result := nil;
  end;
  fs.Free;
end;

procedure TCache.InitPath;
begin
  if (FAccount_Name = '') or (FID = '') then exit;
  FPicturePath := Format('%s\%s\%s\%s\Pictures', [Cache_Path,
    FID, TypeStrings[FAccount_Type], Account_Name]);
  FSNSContextPath := Format('%s\%s\%s\%s\Contexts', [Cache_Path,
    FID, TypeStrings[FAccount_Type], Account_Name]);
  if not DirectoryExists(FPicturePath) then
    ForceDirectories(FPicturePath);
  if not DirectoryExists(FSNSContextPath) then
    ForceDirectories(FSNSContextPath);
end;

procedure TCache.SetAccount_Name(const Value: string);
begin
  FAccount_Name := Value;
  InitPath;
end;

procedure TCache.SetAccount_Type(const Value: TAccount_Type);
begin
  FAccount_Type := Value;
  InitPath;
end;

procedure TCache.SetID(const Value: string);
begin
  FID := Value;
  InitPath;
end;

function TCache.SetPicture(fn: string; pic: TGraphic): boolean;
begin
  result := False;
  CheckPath;
  pic.SaveToFile(Format('%s\%s', [FPicturePath, fn]));
  result := True;
end;

initialization
  Init;

finalization
  Uninit;

end.
