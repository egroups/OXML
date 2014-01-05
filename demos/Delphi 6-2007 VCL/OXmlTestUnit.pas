unit OXmlTestUnit;

{.$DEFINE USE_OMNIXML}//define/undefine to compare OXml with OmniXML
{.$DEFINE USE_NATIVEXML}//define/undefine to compare OXml with NativeXML
{.$DEFINE USE_VERYSIMPLE}//define/undefine to compare OXml with VerySimpleXML

{$IFDEF FPC}
  {$DEFINE USE_GENERICS}
{$ELSE}
  {$IF CompilerVersion >= 20}//D2009
    {$DEFINE USE_GENERICS}
  {$IFEND}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ODictionary,
  {$IFDEF USE_OMNIXML}
  OmniXML,
  {$ENDIF}
  {$IFDEF USE_NATIVEXML}
  NativeXml,
  {$ENDIF}
  {$IFDEF USE_VERYSIMPLE}
  Xml.VerySimple,
  {$ENDIF}
  OEncoding, OBufferedStreams, OHashedStrings,
  OWideSupp, OTextReadWrite, OXmlReadWrite, OXmlUtils,
  {$IFDEF USE_INTF}
  OXmlIntfDOM,
  {$ENDIF}
  OXmlPDOM, OXmlSAX, OXmlSeq;

type
  TForm1 = class(TForm)
    BtnXmlDirectWrite: TButton;
    BtnResaveWithDOM: TButton;
    BtnTestXPath: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    BtnTestSAX: TButton;
    BtnInterfaceCreate: TButton;
    LblTimeInfo: TLabel;
    BtnTestWriteInvalid: TButton;
    BtnEncodingTest: TButton;
    BtnIterateTest: TButton;
    BtnSequentialTest: TButton;
    BtnTestReadInvalid: TButton;
    BtnDOMTest: TButton;
    procedure BtnXmlDirectWriteClick(Sender: TObject);
    procedure BtnResaveWithDOMClick(Sender: TObject);
    procedure BtnTestXPathClick(Sender: TObject);
    procedure BtnTestSAXClick(Sender: TObject);
    procedure BtnInterfaceCreateClick(Sender: TObject);
    procedure BtnTestWriteInvalidClick(Sender: TObject);
    procedure BtnEncodingTestClick(Sender: TObject);
    procedure BtnIterateTestClick(Sender: TObject);
    procedure BtnSequentialTestClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnTestReadInvalidClick(Sender: TObject);
    procedure BtnDOMTestClick(Sender: TObject);
  private
    DocDir: String;

    procedure SAXStartDocument(Sender: TSAXParser);
    procedure SAXEndDocument(Sender: TSAXParser);
    procedure SAXCharacters(Sender: TSAXParser; const aText: OWideString; var aStop: Boolean);
    procedure SAXComment(Sender: TSAXParser; const aText: OWideString; var aStop: Boolean);
    procedure SAXProcessingInstruction(Sender: TSAXParser; const aTarget, aContent: OWideString; var aStop: Boolean);
    procedure SAXStartElement(Sender: TSAXParser; const aName: OWideString;
      const aAttributes: TSAXAttributes; var aStop: Boolean);
    procedure SAXEndElement(Sender: TSAXParser; const aName: OWideString; var aStop: Boolean);
  protected
    procedure DoCreate; override;
  end;

function SAXEscapeString(const aString: OWideString): OWideString;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BtnResaveWithDOMClick(Sender: TObject);
  {$IFDEF USE_OMNIXML}
  procedure TestOmniXmlDOM;
  var
    xXml: OmniXml.IXMLDocument;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OmniXml.CreateXMLDoc;
    xXml.WhiteSpaceHandling := OmniXML.wsPreserveAll;//enable/disable according to OmniXML mod
    //xXml.PreserveWhiteSpace := True;//enable/disable according to OmniXML mod
    xXml.Load(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    xXml.Save(DocDir+'sheet1-resave.xml');

    xXml := nil;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM'+sLineBreak+
      'Whole: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestOmniXmlDOM_MS;
  var
    xXml: OmniXml.IXMLDocument;
    xT1, xT2: Cardinal;
    xMS: TMemoryStream;
  begin
    xT1 := GetTickCount;
    xXml := OmniXml.CreateXMLDoc;
    xXml.WhiteSpaceHandling := OmniXML.wsPreserveAll;//enable/disable according to OmniXML mod
    //xXml.PreserveWhiteSpace := True;//enable/disable according to OmniXML mod
    xXml.Load(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    xMS := TMemoryStream.Create;
    try
      xXml.SaveToStream(xMS);
      xMS.Position := 0;
      xMS.SaveToFile(DocDir+'sheet1-resave.xml');
    finally
      xMS.Free;
    end;

    xXml := nil;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM (TMemoryStream)'+sLineBreak+
      'Whole: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  procedure TestNativeXmlDOM;
  var
    xXml: NativeXml.TNativeXml;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := NativeXml.TNativeXml.Create(nil);
    try
      xXml.XmlFormat := NativeXml.xfPreserve;
      xXml.LoadFromFile(DocDir+'sheet1.xml');
      xT2 := GetTickCount;
      xXml.SaveToFile(DocDir+'sheet1-resave.xml');

      FreeAndNil(xXml);

      Memo1.Lines.Text :=
        Memo1.Lines.Text+sLineBreak+
        'NativeXml DOM'+sLineBreak+
        'Whole: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
        'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
        'Write: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
        sLineBreak+sLineBreak;
    finally
      xXml.Free;
    end;
  end;
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  procedure TestVerySimpleXmlDOM;
  var
    xXml: Xml.VerySimple.TXmlVerySimple;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := Xml.VerySimple.TXmlVerySimple.Create;
    try
      xXml.LoadFromFile(DocDir+'sheet1.xml');
      xT2 := GetTickCount;
      xXml.SaveToFile(DocDir+'sheet1-resave.xml');

      FreeAndNil(xXml);

      Memo1.Lines.Text :=
        Memo1.Lines.Text+sLineBreak+
        'VerySimpleXML DOM'+sLineBreak+
        'Whole: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
        'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
        'Write: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
        sLineBreak+sLineBreak;
    finally
      xXml.Free;
    end;
  end;
  {$ENDIF}

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'sheet1.xml');
    xT2 := GetTickCount;
    xXml.SaveToFile(DocDir+'sheet1-resave.xml');

    xXml := nil;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM (default)'+sLineBreak+
      'Whole: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure TestDirect;
    procedure Nothing(const {%H-}aStr1, {%H-}aStr2: OWideString);
    begin
    end;
  var
    xFSReader, xFSWriter: TFileStream;
    xE: TOXmlReaderNode;
    xXmlReader: TOXmlReader;
    xXmlWriter: TOXmlWriter;
    xT1, xT2: Cardinal;
  begin
    xT1 := GetTickCount;
    xFSReader := TFileStream.Create(DocDir+'sheet1.xml', fmOpenRead);
    xXmlReader := TOXmlReader.Create(xFSReader);
    xFSWriter := TFileStream.Create(DocDir+'sheet1-resave.xml', fmCreate);
    xXmlWriter := TOXmlWriter.Create(xFSWriter, TEncoding.UTF8, False);
    try
      //simulate reading
      while xXmlReader.ReadNextNode({%H-}xE) do begin
        Nothing(xE.NodeName, xE.NodeValue);
      end;
      xXmlReader.Free;
      xT2 := GetTickCount;

      //read+write
      xFSReader.Position := 0;
      xXmlReader := TOXmlReader.Create(xFSReader);

      xXmlWriter.XmlDeclaration(True);
      while xXmlReader.ReadNextNode(xE) do begin
        case xE.NodeType of
          etAttribute: xXmlWriter.Attribute(xE.NodeName, xE.NodeValue);
          etOpenElement: xXmlWriter.OpenElement(xE.NodeName);
          etFinishOpenElement: xXmlWriter.FinishOpenElement;
          etFinishOpenElementClose: xXmlWriter.FinishOpenElementClose;
          etCloseElement: xXmlWriter.CloseElement(xE.NodeName);
          etText: xXmlWriter.Text(xE.NodeValue);
          etCData: xXmlWriter.CData(xE.NodeValue);
          etComment: xXmlWriter.Comment(xE.NodeValue);
          etProcessingInstruction: xXmlWriter.ProcessingInstruction(xE.NodeName, xE.NodeValue);
        end;
      end;
    finally
      xXmlReader.Free;
      xXmlWriter.Free;
      xFSReader.Free;
      xFSWriter.Free;
    end;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml direct reader/writer'+sLineBreak+
      'Whole: '+FloatToStr((GetTickCount-xT2) / 1000)+sLineBreak+
      'Read: '+FloatToStr((xT2-xT1) / 1000)+sLineBreak+
      'Write: '+FloatToStr(((GetTickCount-xT2)-(xT2-xT1)) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  procedure TestSAX;
  var
    xSAX: TSAXParser;
    xT1: Cardinal;
  begin
    xT1 := GetTickCount;

    xSAX := TSAXParser.CreateFromFile(DocDir+'sheet1.xml');
    try
      xSAX.Parse;
    finally
      xSAX.Free;
    end;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml SAX'+sLineBreak+
      'Read: '+FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;

  procedure MatchTestFiles;
  var
    xFS1, xFS2: TFileStream;
    xReader1, xReader2: TOTextReader;
    xC1, xC2: OWideChar;
    I: Integer;
  begin
    xC1 := #0;
    xC2 := #0;
    xFS1 := nil;
    xFS2 := nil;
    xReader1 := nil;
    xReader2 := nil;
    try
      xFS1 := TFileStream.Create(DocDir+'sheet1.xml', fmOpenRead);
      xFS2 := TFileStream.Create(DocDir+'sheet1-resave.xml', fmOpenRead);
      xReader1 := TOTextReader.Create(xFS1);
      xReader2 := TOTextReader.Create(xFS2);

      //start comparing after PI
      while (xC1 <> '>') do
        if not xReader1.ReadNextChar(xC1) then
          Break;
      while xC2 <> '>' do
        if not xReader2.ReadNextChar(xC2) then
          Break;
      xReader1.ReadNextChar(xC1);
      xReader2.ReadNextChar(xC2);
      while OXmlIsWhiteSpaceChar(xC1) do
        if not xReader1.ReadNextChar(xC1) then
          Break;
      while OXmlIsWhiteSpaceChar(xC2) do
        if not xReader2.ReadNextChar(xC2) then
          Break;

      while True do begin
        xReader1.ReadNextChar(xC1);
        xReader2.ReadNextChar(xC2);
        if xC1 <> xC2 then begin
          //get some information
          xReader1.ClearCustomBuffer;
          xReader2.ClearCustomBuffer;
          xReader1.WritePreviousCharToBuffer;
          xReader2.WritePreviousCharToBuffer;
          for I := 0 to 19 do begin
            xReader1.ReadNextChar(xC1);
            xReader2.ReadNextChar(xC2);
            xReader1.WritePreviousCharToBuffer;
            xReader2.WritePreviousCharToBuffer;
          end;

          raise Exception.Create('Files do not match:'+sLineBreak+
            'Reader1 = '+xReader1.GetCustomBuffer+sLineBreak+
            'Reader2 = '+xReader2.GetCustomBuffer+sLineBreak);
        end;

        if (xC1 = #0) or (xC2 = #0) then
          Break;
      end;
    finally
      xReader1.Free;
      xReader2.Free;
      xFS1.Free;
      xFS2.Free;
    end;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  {$IFDEF USE_OMNIXML}
  TestOmniXmlDOM;
  MatchTestFiles;//comment/uncomment to check if files match

  //TestOmniXmlDOM_MS;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  TestNativeXmlDOM;
  MatchTestFiles;//comment/uncomment to check if files match
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  TestVerySimpleXmlDOM;
  MatchTestFiles;//comment/uncomment to check if files match
  {$ENDIF}

  TestOXmlPDOM;
  MatchTestFiles;//comment/uncomment to check if files match

  TestSAX;

  TestDirect;
  MatchTestFiles;//comment/uncomment to check if files match
end;

procedure TForm1.BtnSequentialTestClick(Sender: TObject);
  procedure TestSeq(const aXML: OWideString; aMemo: TMemo);
  var
    xSeqParser: TXMLSeqParser;
    xNode, xAttr: OXmlPDOM.PXMLNode;
    xItemsElementIsOpen: Boolean;
    xName, xColor, xText: OWideString;
  begin
    xSeqParser := TXMLSeqParser.CreateFromXML(aXML);
    try
      if not xSeqParser.GoToPath('/root/items:test') then
        raise Exception.Create('Wrong XML document.');

      if not xSeqParser.ReadNextChildElementHeader({%H-}xNode, {%H-}xItemsElementIsOpen) then
        raise Exception.Create('Wrong XML document.');

      aMemo.Lines.Add(xNode.XML);

      if xItemsElementIsOpen then begin
        while xSeqParser.ReadNextChildNode(xNode) do
        begin
          if (xNode.NodeType = ntElement) and
             (xNode.NodeName = 'item')
          then begin
            if xNode.FindAttribute('color', {%H-}xAttr) then
              xColor := xAttr.NodeValue
            else
              xColor := '[default]';
            xName := xNode.Attributes['name'];
            xText := xNode.Text;

            aMemo.Lines.Add(xNode.XML);
            aMemo.Lines.Add('  -> '+xName+':'+xColor+':'+xText);
          end;
        end;
      end;

      while xSeqParser.ReadNextChildElementHeaderClose(xNode) do
      begin
        if (xNode.NodeType = ntElement) and
           (xNode.NodeName = 'info')
        then
          aMemo.Lines.Add(xNode.XML);
      end;
    finally
      xSeqParser.Free;
    end;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestSeq(
    '<root>'+
      '<items:test defaultcolor="red">'+
        '<item name="car" color="blue" />'+
        '<skip>Skip this element</skip>'+
        '<item name="bike">bike has <b>default</b> color!</item>'+
        '<item name="tree" color="green" />'+
      '</items:test>'+
      '<info text="Yes, I want to know it!" />'+
      'skip texts'+
      '<info text="Show me!" />'+
    '</root>',
  Memo1);

  TestSeq(
    '<root>'+
      '<items:test defaultcolor="red" />'+
      'skip texts'+
      '<info text="Yes, I want to know it!">'+
        'skip this information'+
        '<skip>all elements in info tag are not read</skip>'+
      '</info>'+
      '<info text="Show me!" />'+
    '</root>',
  Memo2);

end;

function SAXEscapeString(const aString: OWideString): OWideString;
begin
  Result := aString;
  Result := OStringReplace(Result, sLineBreak, '\n', [rfReplaceAll]);
  Result := OStringReplace(Result, '"', '\"', [rfReplaceAll]);
end;

procedure TForm1.BtnTestWriteInvalidClick(Sender: TObject);

  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
    xRoot: OXmlPDOM.PXMLNode;
  begin
    xXML := OXmlPDOM.CreateXMLDoc('root');
    xXML.WriterSettings.StrictXML := False;//set to true/false - allow/disallow invalid document
    xXML.ReaderSettings.StrictXML := False;//set to true/false - allow/disallow invalid document

    //comment/uncomment to test validity
    xRoot := xXML.DocumentElement;
    xRoot.Attributes['0name'] := 'test';//invalid attribute name
    xRoot.AddChild('0name');//invalid name
    xRoot.AddComment('te--st');//invalid comment (a comment cannot contain "--" string
    xRoot.AddCDATASection('te]]>st');//invalid cdata (a cdata section cannot contain "]]>" string

    Memo2.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.BtnTestReadInvalidClick(Sender: TObject);
const
  cXML: OWideString =
    '<root>'+sLineBreak+
    '  <item < AttributeWithoutValue attr2 = value2 attr3  =  "value3"  ? />'+sLineBreak+
    '  <![aaa'+sLineBreak+
    '  kolo >'+sLineBreak+
    '  <test />>'+sLineBreak+
    '  <!-x'+sLineBreak+
    '  <!'+sLineBreak+
    '  <!rr'+sLineBreak+
    '  <!DOC'+
    '  <<<'+sLineBreak+
    ' &nbsp ; '+sLineBreak+
    '  <lo.ko> <para> <b> TEXT </i> </lo.ko>'+
    '  <? = aaa ?>'+
    '  <?= aaa ?>'+
    '  <?aaa ?>'+
    '  <??>'+
    '</root>';

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
  begin
    xXML := OXmlPDOM.CreateXMLDoc;
    xXML.ReaderSettings.StrictXML := False;//set to true/false - allow/disallow invalid document
    xXML.WriterSettings.StrictXML := False;//set to true/false - allow/disallow invalid document

    xXML.WhiteSpaceHandling := wsPreserveAll;
    xXML.LoadFromXML(cXML);

    Memo2.Lines.Add('OXml record based DOM:');
    Memo2.Lines.Text := Memo2.Lines.Text + xXML.XML;
  end;
begin
  Memo1.Lines.Text :=
    'Original invalid XML:'+sLineBreak+sLineBreak+
    cXML;
  Memo2.Lines.Text :=
    'XML as it is read and understood by OXml:'+sLineBreak+sLineBreak;

  TestOXmlPDOM;
end;

procedure TForm1.BtnTestSAXClick(Sender: TObject);
var
  xSAX: TSAXParser;
const
  cXML: OWideString =
    '<?xml version="1.0"?>'+sLineBreak+
    '<seminararbeit>'+sLineBreak+
    ' <titel>DOM, SAX und SOAP</titel>'+sLineBreak+
    ' <inhalt>'+sLineBreak+
    '  <kapitel value="1">Einleitung</kapitel>'+sLineBreak+
    '  <kapitel value="2">Hauptteil</kapitel>'+sLineBreak+
    '  <kapitel value="3">Fazit</kapitel>'+sLineBreak+
    ' </inhalt>'+sLineBreak+
    ' <!-- comment -->'+sLineBreak+
    ' <![CDATA[ cdata ]]>'+sLineBreak+
    ' <?php echo "custom processing instruction" ?>'+sLineBreak+
    '</seminararbeit>'+sLineBreak;
begin
  Memo1.Lines.Text := 'Events:'+sLineBreak+sLineBreak;
  Memo2.Lines.Text := 'Anonymous methods:'+sLineBreak+sLineBreak;

  xSAX := TSAXParser.CreateFromXML(cXML);
  try
    //old-fashioned events
    xSAX.OnStartDocument := SAXStartDocument;
    xSAX.OnEndDocument := SAXEndDocument;
    xSAX.OnCharacters := SAXCharacters;
    xSAX.OnComment := SAXComment;
    xSAX.OnProcessingInstruction := SAXProcessingInstruction;
    xSAX.OnStartElement := SAXStartElement;
    xSAX.OnEndElement := SAXEndElement;

    {$IFNDEF FPC}{$IF CompilerVersion >= 20}
    //anonymous methods
    xSAX.StartDocumentProc := (
      procedure
      begin
        Memo2.Lines.Add('startDocument()');
      end);

    xSAX.EndDocumentProc := (
      procedure
      begin
        Memo2.Lines.Add('endDocument()');
      end);

    xSAX.CharactersProc := (
      procedure(const aText: OWideString; var aStop: Boolean)
      begin
        Memo2.Lines.Add('characters("'+SAXEscapeString(aText)+'")');
      end);

    xSAX.CommentProc := (
      procedure(const aText: OWideString; var aStop: Boolean)
      begin
        Memo2.Lines.Add('comment("'+SAXEscapeString(aText)+'")');
      end);

    xSAX.ProcessingInstructionProc := (
      procedure(const aTarget, aContent: OWideString; var aStop: Boolean)
      begin
        Memo2.Lines.Add('processingInstruction("'+SAXEscapeString(aTarget)+'", "'+SAXEscapeString(aContent)+'")');
      end);

    xSAX.StartElementProc := (
      procedure(const aName: OWideString;
        const aAttributes: TSAXAttributes; var aStop: Boolean)
      var
        xAttrStr: OWideString;
        xAttr: TSAXAttribute;
      begin
        xAttrStr := '';
        for xAttr in aAttributes do begin
          if xAttrStr <> '' then
            xAttrStr := xAttrStr + ';';
          xAttrStr := xAttrStr + SAXEscapeString(xAttr.Key)+'="'+SAXEscapeString(xAttr.Value)+'"';
        end;
        xAttrStr := '['+xAttrStr+']';

        Memo2.Lines.Add('startElement("'+SAXEscapeString(aName)+'", '+xAttrStr+')');
      end);

    xSAX.EndElementProc := (
      procedure(const aName: OWideString; var aStop: Boolean)
      begin
        Memo2.Lines.Add('endElement("'+SAXEscapeString(aName)+'")');
      end);
    {$IFEND}{$ENDIF}

    xSAX.Parse;
  finally
    xSAX.Free;
  end;
end;

procedure TForm1.BtnTestXPathClick(Sender: TObject);
const
  cXML: OWideString =
    //'  '+sLineBreak+'  '+
    '<?xml version="1.0" encoding="utf-8" ?>'+
    '<root description="test xml">'+
      '<boss name="Max Muster">'+
        '<person name="boss person"/>'+
        '<person name="boss person 2">'+
          '<person name="boss person/2.1"/>'+
          '<dog name="boss dog 2.2" type="fight" />'+
        '</person>'+
      '</boss>'+
      '<!-- comment -->'+
      '<person name="Paul Caster">this text is in person tag</person>'+
      '<![CDATA[some test info]]>'+
      '<?pi processing instruction ?>'+
    '</root>';

  {$IFDEF USE_OMNIXML}
  procedure TestOmniXML;
  var
    xXml: OmniXML.IXMLDocument;

    procedure _TestXPathElements(const aStartNode: OmniXML.IXMLNode; const aXPath, aResult: OWideString);
    var
      xList: OmniXML.IXMLNodeList;
      xElement: OmniXML.IXMLNode;
      xAttr: OmniXML.IXMLNode;
      xStr: OWideString;
      I: Integer;
    begin
      aStartNode.SelectNodes(aXPath, {%H-}xList);
      if xList.Length > 0 then begin
        xStr := '';
        for I := 0 to xList.Length-1 do begin
          xElement := xList.Item[I];

          if xStr <> '' then
            xStr := xStr+sLineBreak;
          case xElement.NodeType of
            ELEMENT_NODE: begin
              xStr := xStr+xElement.NodeName+'=';
              xAttr := xElement.Attributes.GetNamedItem('name');
              if Assigned(xAttr) then
                xStr := xStr+xAttr.NodeValue;
            end;
            ATTRIBUTE_NODE: xStr := xStr+xElement.ParentNode.NodeName+':'+xElement.NodeName+'='+xElement.NodeValue;
            TEXT_NODE, CDATA_SECTION_NODE: xStr := xStr+xElement.NodeValue;
          end;
        end;

        if xStr <> aResult then begin
          Memo1.Lines.Text := (
            'XPath test failed: '+aXPath+sLineBreak+
              xStr+sLineBreak+
              '-----'+sLineBreak+
              aResult);
          raise Exception.Create(Form1.Memo1.Lines.Text);
        end;
      end else begin
        raise Exception.Create('XPath test failed (nothing selected): '+aXPath);
      end;
    end;
  begin
    xXml := OmniXML.CreateXMLDoc;

    xXml.LoadXML(cXML);

    _TestXPathElements(xXml.DocumentElement, '.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/boss/..', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/person', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml.DocumentElement, '..//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    //not supported by OmniXML:_TestXPathElements(xXml.DocumentElement, '//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    //not supported by OmniXML:_TestXPathElements(xXml, '//person[@name]', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, '//root//person/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    //OmniXML: ERROR _TestXPathElements(xXml, '//person/../../boss', 'boss=Max Muster');
    _TestXPathElements(xXml, '//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root//boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml, 'root//*', 'boss=Max Muster'+sLineBreak+'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root/*', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, '/root/boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml, 'root/boss', 'boss=Max Muster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/person|root/boss', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml, 'root', 'root=');
    _TestXPathElements(xXml, 'root/boss/person[2]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml, 'root/person[1]', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/person[last()]', 'person=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, '/root/*[last()-1]/person[last()]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    //not supported by OmniXML:_TestXPathElements(xXml, '//text()', 'this text is in person tag'+sLineBreak+'some test info');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root/node()', 'root:description=test xml'+sLineBreak+'boss=Max Muster'+sLineBreak+'person=Paul Caster'+sLineBreak+'some test info');

    //not supported by OmniXML:_TestXPathElements(xXml, 'root//@*', 'root:description=test xml'+sLineBreak+'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'dog:type=fight'+sLineBreak+'person:name=Paul Caster');
    //not supported by OmniXML:_TestXPathElements(xXml, 'root//@name', 'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'person:name=Paul Caster');

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM: All XPath tests succeeded.';
  end;
  {$ENDIF}

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;

    procedure _TestXPathElements(const aStartNode: OXmlPDOM.PXMLNode; const aXPath, aResult: OWideString);
    var
      xList: OXmlPDOM.IXMLNodeList;
      xElement: OXmlPDOM.PXMLNode;
      xStr: OWideString;
      {$IFNDEF USE_FORIN}
      I: Integer;
      {$ENDIF}
    begin
      if aStartNode.SelectNodes(aXPath, {%H-}xList) then begin
        xStr := '';
        {$IFDEF USE_FORIN}
        for xElement in xList do begin
        {$ELSE}
        for I := 0 to xList.Count-1 do begin
          xElement := xList[I];
        {$ENDIF}
          if xStr <> '' then
          if xStr <> '' then
            xStr := xStr+sLineBreak;
          case xElement.NodeType of
            ntElement: xStr := xStr+xElement.NodeName+'='+xElement.Attributes['name'];
            ntAttribute: xStr := xStr+xElement.ParentNode.NodeName+':'+xElement.NodeName+'='+xElement.NodeValue;
            ntText, ntCData: xStr := xStr+xElement.NodeValue;
          end;
        end;

        if xStr <> aResult then begin
          Memo1.Lines.Text := (
            'XPath test failed: '+aXPath+sLineBreak+
              xStr+sLineBreak+
              '-----'+sLineBreak+
              aResult);
          raise Exception.Create(Memo1.Lines.Text);
        end;
      end else begin
        raise Exception.Create('XPath test failed (nothing selected): '+aXPath);
      end;
    end;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml := TXMLDocument.Create(nil);
    xXml.LoadFromXML(cXML);

    _TestXPathElements(xXml.DocumentElement, '.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/.', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/boss/..', 'root=');
    _TestXPathElements(xXml.DocumentElement, '../root/person', 'person=Paul Caster');
    _TestXPathElements(xXml.DocumentElement, '..//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    _TestXPathElements(xXml.DocumentElement, '//person[@name="boss person/2.1"]', 'person=boss person/2.1');
    _TestXPathElements(xXml.Node, '//person[@name]', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, '//root//person/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, '//person/../../boss', 'boss=Max Muster');
    _TestXPathElements(xXml.Node, '//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//person', 'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml.Node, 'root//*', 'boss=Max Muster'+sLineBreak+'person=boss person'+sLineBreak+'person=boss person 2'+sLineBreak+'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root/*', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, '/root/boss/person', 'person=boss person'+sLineBreak+'person=boss person 2');
    _TestXPathElements(xXml.Node, 'root/boss', 'boss=Max Muster');
    _TestXPathElements(xXml.Node, 'root/person|root/boss', 'boss=Max Muster'+sLineBreak+'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root', 'root=');
    _TestXPathElements(xXml.Node, 'root/boss/person[2]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, 'root/person[1]', 'person=Paul Caster');
    _TestXPathElements(xXml.Node, 'root/person[last()]', 'person=Paul Caster');
    _TestXPathElements(xXml.Node, '/root/*[last()-1]/person[last()]/*', 'person=boss person/2.1'+sLineBreak+'dog=boss dog 2.2');
    _TestXPathElements(xXml.Node, '//text()', 'this text is in person tag'+sLineBreak+'some test info');
    _TestXPathElements(xXml.Node, 'root/node()', 'root:description=test xml'+sLineBreak+'boss=Max Muster'+sLineBreak+'person=Paul Caster'+sLineBreak+'some test info');


    _TestXPathElements(xXml.Node, 'root//@*', 'root:description=test xml'+sLineBreak+'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'dog:type=fight'+sLineBreak+'person:name=Paul Caster');
    _TestXPathElements(xXml.Node, 'root//@name', 'boss:name=Max Muster'+sLineBreak+'person:name=boss person'+sLineBreak+'person:name=boss person 2'+sLineBreak+'person:name=boss person/2.1'+sLineBreak+'dog:name=boss dog 2.2'+sLineBreak+'person:name=Paul Caster');

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM: All XPath tests succeeded.';
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  {$IFDEF USE_OMNIXML}
  TestOmniXML;
  {$ENDIF}

  TestOXmlPDOM;
end;

procedure TForm1.BtnIterateTestClick(Sender: TObject);
const
  cXML: OWideString =
    '<root attr1="z" attr2="o" attr3="3x" attr4="y4">'+
      '<element1>Hello</element1>'+
      '<element2>Bye</element2>'+
      '<element3/>'+
    '</root>';

  {$IFDEF USE_FORIN}
  procedure TestOXmlPDOMForIn;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    for xNode in xXML.DocumentElement.ChildNodes do
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo2.Lines.Add('');
  end;
  {$ENDIF}

  procedure TestOXmlPDOMForTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := 0 to xRoot.ChildNodes.Count-1 do begin
      xNode := xRoot.ChildNodes[I];
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);
    end;

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMForDownTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := xRoot.ChildNodes.Count-1 downto 0 do begin
      xNode := xRoot.ChildNodes[I];
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);
    end;

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextChild;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetNextChild(xNode) do
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMPreviousChild;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetPreviousChild(xNode) do
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextSibling;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xNode := xXML.DocumentElement.FirstChild;
    while Assigned(xNode) do begin
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);
      xNode := xNode.NextSibling;
    end;

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMPreviousSibling;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xNode := xXML.DocumentElement.LastChild;
    while Assigned(xNode) do begin
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.Text);
      xNode := xNode.PreviousSibling;
    end;

    Memo2.Lines.Add('');
  end;

  {$IFDEF USE_FORIN}
  procedure TestOXmlPDOMAttributesForIn;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    for xNode in xXML.DocumentElement.AttributeNodes do
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);

    Memo2.Lines.Add('');
  end;
  {$ENDIF}

  procedure TestOXmlPDOMAttributesForTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := 0 to xRoot.AttributeNodes.Count-1 do begin
      xNode := xRoot.AttributeNodes[I];
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);
    end;

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMAttributesForDownTo;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
    I: Integer;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    for I := xRoot.AttributeNodes.Count-1 downto 0 do begin
      xNode := xRoot.AttributeNodes[I];
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);
    end;

    Memo2.Lines.Add('');
  end;

  procedure TestOXmlPDOMNextAttribute;
  var
    xXml: OXmlPDOM.IXMLDocument;
    xRoot, xNode: OXmlPDOM.PXMLNode;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.LoadFromXML(cXML);

    xRoot := xXML.DocumentElement;
    xNode := nil;
    while xRoot.GetNextAttribute(xNode) do
      Memo2.Lines.Add(xNode.NodeName+': '+xNode.NodeValue);

    Memo2.Lines.Add('');
  end;

begin
  Memo1.Lines.BeginUpdate;
  Memo2.Lines.BeginUpdate;
  try
    Memo1.Lines.Clear;
    Memo2.Lines.Clear;

    {$IFDEF USE_FORIN}
    TestOXmlPDOMForIn;
    {$ENDIF}
    TestOXmlPDOMForTo;
    TestOXmlPDOMForDownTo;
    TestOXmlPDOMNextChild;
    TestOXmlPDOMNextSibling;
    TestOXmlPDOMPreviousChild;
    TestOXmlPDOMPreviousSibling;
    {$IFDEF USE_FORIN}
    TestOXmlPDOMAttributesForIn;
    {$ENDIF}
    TestOXmlPDOMAttributesForTo;
    TestOXmlPDOMAttributesForDownTo;
    TestOXmlPDOMNextAttribute;

  finally
    Memo1.Lines.EndUpdate;
    Memo2.Lines.EndUpdate;
  end;
end;

procedure TForm1.BtnDOMTestClick(Sender: TObject);
  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
    xRoot: OXmlPDOM.PXMLNode;
    xChild1, xChild2, xChild3, xReplacedChild: OXmlPDOM.PXMLNode;
    xAttribute: OXmlPDOM.PXMLNode;
  begin
    xXML := OXmlPDOM.CreateXMLDoc('root');

    xRoot := xXML.DocumentElement;

    xChild1 := xXML.CreateElement('test');
    xRoot.AppendChild(xChild1);

    xAttribute := xXML.CreateAttribute('attr', 'value');
    xChild1.SetAttributeNode(xAttribute);

    xChild2 := xXML.CreateElement('child2');
    xRoot.InsertBefore(xChild2, xChild1);

    xChild3 := xXML.CreateElement('node3');
    xReplacedChild := xRoot.ReplaceChild(xChild3, xChild2);
    if Assigned(xReplacedChild) then//the replaced child doesn't get destroyed automatically
      xReplacedChild.DeleteSelf;//free the old child

    Memo2.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.BtnEncodingTestClick(Sender: TObject);
  procedure TestOXmlPDOM;
  var
    xXML: OXmlPDOM.IXMLDocument;
  begin
    xXML := OXmlPDOM.CreateXMLDoc;

    xXML.LoadFromFile(DocDir+'koi8-r.xml');
    xXML.DocumentElement.NodeName := 'rootnode';
    xXML.DocumentElement.SelectNode('load').LoadFromXML('some <i>text</i> with <b>tags</b>');
    xXML.CodePage := CP_WIN_1251;
    xXML.SaveToFile(DocDir+'1251.xml');

    xXML.WriterSettings.IndentType := itIndent;
    Memo2.Lines.Text := xXML.XML;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  TestOXmlPDOM;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Memo1.SetBounds(0, LblTimeInfo.BoundsRect.Bottom + 5, ClientWidth div 2, ClientHeight-LblTimeInfo.BoundsRect.Bottom - 5);
  Memo2.SetBounds(Memo1.BoundsRect.Right, Memo1.BoundsRect.Top, ClientWidth-Memo1.BoundsRect.Right, Memo1.Height);
end;

procedure TForm1.BtnInterfaceCreateClick(Sender: TObject);
  {$IFDEF USE_OMNIXML}
  procedure OmniXmlTest;
  var
    I: Integer;
    xT1: Cardinal;
    xXML: OmniXml.IXMLDocument;
    xRootNode, xNode, xNewChild, xFirstNode: OmniXml.IXMLNode;
    xNewAttr: OmniXml.IXMLAttr;
  begin
    xT1 := GetTickCount;

    xXML := OmniXml.CreateXMLDoc;
    xXML.DocumentElement := xXML.CreateElement('root');
    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNewChild := xXML.CreateElement('text');
      xNode := xRootNode.AppendChild(xNewChild);
      xFirstNode := xNode;

      xNewChild := xXML.CreateElement('A'+IntToStr(I));
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('noname');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('some');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateElement('p');
      xNode := xNode.AppendChild(xNewChild);

      xNewChild := xXML.CreateTextNode('afg');
      xNode := xNode.AppendChild(xNewChild);

      xNewAttr := xXML.CreateAttribute('attr1');
      xNewAttr.Value := 'A'+IntToStr(I);
      xFirstNode.Attributes.Add(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr2');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.Add(xNewAttr);
      xNewAttr := xXML.CreateAttribute('attr3');
      xNewAttr.Value := 'const';
      xFirstNode.Attributes.Add(xNewAttr);
    end;

    xRootNode := nil;
    xNode := nil;
    xXML := nil;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OmniXML DOM'+sLineBreak+
      FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_NATIVEXML}
  procedure NativeXmlTest;
  var
    I: Integer;
    xT1: Cardinal;
    xXML: NativeXml.TNativeXml;
    xRootNode, xNode, xNodeN: NativeXml.TXmlNode;
  begin
    xT1 := GetTickCount;

    xXML := NativeXml.TNativeXml.CreateEx(nil, False, False, True, 'root');
    try
      xRootNode := xXML.Root;
      for I := 1 to 100*1000 do begin
        xNode := xXML.NodeNew('text');
        xRootNode.NodeAdd(xNode);

        xNode.AttributeAdd('attr1', UTF8Encode('A'+IntToStr(I)));
        xNode.AttributeAdd('attr2', 'const');
        xNode.AttributeAdd('attr3', 'const');

        xNodeN := xXML.NodeNew(UTF8Encode('A'+IntToStr(I)));
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('noname');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('some');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNew('p');
        xNode.NodeAdd(xNodeN);
        xNode := xNodeN;

        xNodeN := xXML.NodeNewTextType('', 'afg', xeCharData);
        xNode.NodeAdd(xNodeN);
      end;
    finally
      xXML.Free;
    end;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'NativeXml DOM'+sLineBreak+
      FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  {$IFDEF USE_VERYSIMPLE}
  procedure VerySimpleXmlTest;
  var
    xXML: Xml.VerySimple.TXmlVerySimple;
    I: Integer;
    xT1: Cardinal;
    xRootNode, xNode: Xml.VerySimple.TXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := Xml.VerySimple.TXmlVerySimple.Create;
    try
      xXML.Root.NodeName := 'root';
      xRootNode := xXML.Root;
      for I := 1 to 100*1000 do begin
        xNode := xRootNode.AddChild('text');
        xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').Text := 'afg';
        xNode.SetAttribute('attr1', 'A'+IntToStr(I));
        xNode.SetAttribute('attr2', 'const');
        xNode.SetAttribute('attr3', 'const');
      end;

      xRootNode := nil;
      xNode := nil;
    finally
      xXML.Free;
    end;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'VerySimpleXML DOM'+sLineBreak+
      FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
  {$ENDIF}

  procedure OXmlPDOMTest;
  var
    xXML: OXmlPDOM.IXMLDocument;
    I: Integer;
    xT1: Cardinal;
    xRootNode, xNode: OXmlPDOM.PXMLNode;
  begin
    xT1 := GetTickCount;

    xXML := OXmlPDOM.CreateXMLDoc('root');
    xRootNode := xXML.DocumentElement;
    for I := 1 to 100*1000 do begin
      xNode := xRootNode.AddChild('text');
      xNode.AddChild('A'+IntToStr(I)).AddChild('noname').AddChild('some').AddChild('p').AddText('afg');
      xNode.Attributes['attr1'] := 'A'+IntToStr(I);
      xNode.Attributes['attr2'] := 'const';
      xNode.Attributes['attr3'] := 'const';
    end;

    xXML := nil;

    Memo1.Lines.Text :=
      Memo1.Lines.Text+sLineBreak+
      'OXml record DOM'+sLineBreak+
      FloatToStr((GetTickCount-xT1) / 1000)+sLineBreak+
      sLineBreak+sLineBreak;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  {$IFDEF USE_OMNIXML}
  OmniXmlTest;
  {$ENDIF}
  {$IFDEF USE_NATIVEXML}
  NativeXmlTest;
  {$ENDIF}
  {$IFDEF USE_VERYSIMPLE}
  VerySimpleXmlTest;
  {$ENDIF}
  OXmlPDOMTest;
end;

procedure TForm1.BtnXmlDirectWriteClick(Sender: TObject);
  procedure WriteDocument;
  var
    xS: TStream;
    xXmlWriter: TOXmlWriter;
    xRootElement, xPersonElement: TOXmlWriterElement;
  begin
    xS := TFileStream.Create(DocDir+'simple.xml', fmCreate);
    xXmlWriter := TOXmlWriter.Create(xS, TEncoding.UTF8);
    try
      xXmlWriter.IndentType := itNone;

      xXmlWriter.DocType('root PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"');
      xXmlWriter.XmlDeclaration(True);

      xRootElement := xXmlWriter.OpenElementR('root');
      xRootElement.Attribute('description', 'test xml');

      xPersonElement := xRootElement.OpenElementR('boss');
      xPersonElement.Attribute('name', '?Max Muster');
      xPersonElement.CloseElement;

      xRootElement.Comment('this is some text in comment');

      xPersonElement := xRootElement.OpenElementR('person');
      xPersonElement.Attribute('name', '/Paul Caster');
      xPersonElement.Text('/this text is in person tag');
      xPersonElement.CloseElement;

      xRootElement.Text('some test info');

      xRootElement.CData('!this is some text in <CDATA> section.');
      xRootElement.ProcessingInstruction('target', '((custom processing instruction.))');

      xRootElement.CloseElement;
    finally
      xXmlWriter.Free;
      xS.Free;
    end;
  end;

  procedure TestOXmlPDOM;
  var
    xXml: OXmlPDOM.IXMLDocument;
  begin
    xXml := OXmlPDOM.CreateXMLDoc;
    xXml.WhiteSpaceHandling := wsPreserveAll;
    xXml.LoadFromFile(DocDir+'simple.xml');
    xXML.WriterSettings.IndentType := itIndent;
    Memo2.Lines.Text :=
      xXml.XML+sLineBreak+sLineBreak+
      '------'+sLineBreak+
      xXml.DocumentElement.Text;
  end;
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;

  //WRITE DOCUMENT
  WriteDocument;

  //READ DOCUMENT AND FORMAT IT NICELY
  TestOXmlPDOM;
end;

procedure TForm1.DoCreate;
begin
  inherited;

  DocDir := ExtractFilePath(Application.ExeName)+'..'+PathDelim+'doc'+PathDelim;

  {$IFNDEF FPC}{$IF CompilerVersion >= 18}//Delphi 2006 UP
  ReportMemoryLeaksOnShutdown := True;
  {$IFEND}{$ENDIF}
end;

procedure TForm1.SAXCharacters(Sender: TSAXParser; const aText: OWideString; var aStop: Boolean);
begin
  Memo1.Lines.Add('characters("'+SAXEscapeString(aText)+'")');
end;

procedure TForm1.SAXComment(Sender: TSAXParser; const aText: OWideString; var aStop: Boolean);
begin
  Memo1.Lines.Add('comment("'+SAXEscapeString(aText)+'")');
end;

procedure TForm1.SAXEndDocument(Sender: TSAXParser);
begin
  Memo1.Lines.Add('endDocument()');
end;

procedure TForm1.SAXEndElement(Sender: TSAXParser; const aName: OWideString; var aStop: Boolean);
begin
  Memo1.Lines.Add('endElement("'+SAXEscapeString(aName)+'")');
end;

procedure TForm1.SAXProcessingInstruction(Sender: TSAXParser; const aTarget,
  aContent: OWideString; var aStop: Boolean);
begin
  Memo1.Lines.Add('processingInstruction("'+SAXEscapeString(aTarget)+'", "'+SAXEscapeString(aContent)+'")');
end;

procedure TForm1.SAXStartDocument(Sender: TSAXParser);
begin
  Memo1.Lines.Add('startDocument()');
end;

procedure TForm1.SAXStartElement(Sender: TSAXParser; const aName: OWideString;
  const aAttributes: TSAXAttributes; var aStop: Boolean);
var
  xAttrStr: OWideString;
  xAttr: TSAXAttribute;
  {$IFNDEF USE_FORIN}
  I: Integer;
  {$ENDIF}
begin
  xAttrStr := '';
  {$IFDEF USE_FORIN}
  for xAttr in aAttributes do begin
  {$ELSE}
  for I := 0 to aAttributes.Count-1 do begin
    xAttr := aAttributes.Pairs[I];
  {$ENDIF}
    if xAttrStr <> '' then
      xAttrStr := xAttrStr + ';';
    xAttrStr := xAttrStr + SAXEscapeString(xAttr.Key)+'="'+SAXEscapeString(xAttr.Value)+'"';
  end;
  xAttrStr := '['+xAttrStr+']';

  Memo1.Lines.Add('startElement("'+SAXEscapeString(aName)+'", '+xAttrStr+')');
end;

end.

