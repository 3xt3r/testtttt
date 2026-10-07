using Newtonsoft.Json;
using Serilog;
using YamlDotNet.Serialization;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

var obj = new { Name = "SCA benchmark", Type = "csproj-no-lock" };
var json = JsonConvert.SerializeObject(obj);

var serializer = new SerializerBuilder().Build();
var yaml = serializer.Serialize(obj);

Log.Information("JSON: {Json}", json);
Console.WriteLine(yaml);
