unit Main;

{��reControl�ŵ�retext��}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NativeXML, Global, User_Intf, Data_Intf, StdCtrls,
  SNSView;

type
  TMainForm = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    User: TUser;
    { Private declarations }
  public
    sns: TSNSViewer;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses web_connect,Jpeg;

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  sns.Update;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  api:TAPICall;
  context:TSNSContext;
  i:integer;
begin
  sns := TSNSViewer.Create(self);
  sns.Parent := self;
  sns.Align := alTop;
  sns.Height := 300;
  context := TSNSContext.Create;
  for I := 0 to 0 do
  begin
  context.AccountName := 'HSFZXJY';
  context.Text := '�����������@HFer__- #����#';
  context.Counts.Good := 12;
  context.ProfileImageURL := 'http://tp2.sinaimg.cn/1772543313/50/40021176578/1';
  sns.AddContext(context);
  end;
  context.Free;
  sns.DoDraw;
end;

end.
