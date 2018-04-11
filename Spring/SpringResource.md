# Resources
## һ������
 Java�б�׼��`java.net.URL`�����Բ�ͬURLǰ׺�ı�׼������Եײ���Դ�����ò�����֡����磬��ǰû�п��õı�׼`URL`ʵ�����ܹ�����·����`ServletContext`�����·����ȡ��Դ��ע���ض�`URL`ǰ׺���´������ǿ��еķ�ʽ���������ַ�ʽͨ���൱���ӡ�ͬʱ`URL`�ӿ�ȱ��һЩʵ�õĹ��ܣ������ж�ָ������Դ�Ƿ���ڵķ�ʽ��  
## ����Resource�ӿ�
 �����`URL`�ӿڣ�Spring��`Resource`�ӿ���ʹ�õײ���Դ�Ϲ��ܸ��ḻ��
 ```
 public interface Resource extends InputStreamSource {

    boolean exists();

    boolean isOpen();

    URL getURL() throws IOException;

    File getFile() throws IOException;

    Resource createRelative(String relativePath) throws IOException;

    String getFilename();

    String getDescription();
 }
 ```
 ```
 public interface InputStreamSource {
    InputStream getInputStream() throws IOException;
 }
 ```
 `Resource`�ӿ��е�һЩ��Ҫ�����ǣ�  
 + `getInputStream()`����λ�ʹ���Դ�����ش���Դ�ж�ȡ����`InputStream`��������ÿ�ε��ö�Ӧ�÷���һ���µ�`InputStream`�������߱���ر��������  
 + `exists()`������һ��booleanֵ����ʾ��Դ�Ƿ��������豸�ϴ��ڡ�  
 + `isOpen()`������һ��booleanֵ����ʾ��Դ�Ƿ��ʾΪ���ѿ������Ĳ��������Ϊtrue����`InputStream`���ܶ�ζ�ȡ��ֻ�ܶ�ȡһ��Ȼ��رշ�ֹ��Դй©������`InputStream` �⣬�������е�resourceʵ���඼��false��
 + `getDescription()`�����ض���Դ�����������ڴ�����Դʱ���쳣�����ͨ�����ļ���ȫ·�����ƻ���Դ��ʵ��URL��  
 
 ����ײ��ʵ����֧�֣����������������ȡ������Դ��ʵ��`URL`��`File`����  
 ��Spring�У�`Resource`����ӿ�Ӧ�ù㷺������Ҫʱ����Ϊ����ǩ����һ���������͡�����Spring API�������������������`ApplicationContext`ʵ����Ĺ��������У�ͨ���ַ��������ʺ�contextʵ�����`Resource`������ͨ���ַ���·����ָ��ǰ׺���������������ָ����`Resource`ʵ������뱻������ʹ�á�  
 `Resource`�ӿ���Spring��ʹ�ù㷺����ʹ��������в���ʹ��Springʱ��`Resource`����Ҳ��һ��������Դ����Ч�����ࡣ��Ὣ������Spring��ϣ�����Ҳ�����������`URL`�ĸ��ḻ����������༯���ȼ���Ϊ���Ŀ��ʹ�õ�����jar����  
 ֵ��ע����ǣ�`Resource`����ӿڲ������滻�����࣬�������ǰ�װ����������ࡣ���磬`URLResource`��װ��URL����ͨ�������װ��`URL`��������Դ��
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 