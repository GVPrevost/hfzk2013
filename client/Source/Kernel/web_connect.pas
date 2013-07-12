unit web_connect;

interface

uses Sysutils, NativeXML, XMLObj;

type

EURLGetError = class (Exception);

function GetStringFromURL(url: string): WideString;
function GetDataFromURL(url: string): TNode;

implementation

function GetStringFromURL(url: string): WideString;
var
  xml: TNativeXML;
begin
  xml := TNativeXML.Create(nil);
  result := '';
  try
    xml.LoadFromURL(url);
    result := xml.WriteToLocalUnicodeString;
  except
    xml.Free;
    raise EURLGetError.Create('Data get failed!');
    exit;
  end;
  xml.Free;
end;

function GetDataFromURL(url: string): TNode;
var
  xml: TNativeXML;
  node: TNode;
begin
  xml := TNativeXML.Create(nil);
  node := TNode.Create(nil);
  try
    xml.LoadFromURL(url);
    node := parse(xml);
  except
    xml.Free;
    FreeAndNil(node);
    result := node;
    raise EURLGetError.Create('Data get failed!');
    exit;
  end;
  xml.Free;
  result := node;
end;

end.
