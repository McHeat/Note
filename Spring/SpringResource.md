# Resources
## һ������
 Java�б�׼��`java.net.URL`�����Բ�ͬURLǰ׺�ı�׼������Եײ���Դ�����ò�����֡�
 ���磬��ǰû�п��õı�׼`URL`ʵ�����ܹ�����·����`ServletContext`�����·����ȡ��Դ��
 ע���ض�`URL`ǰ׺���´������ǿ��еķ�ʽ���������ַ�ʽͨ���൱���ӡ�
 ͬʱ`URL`�ӿ�ȱ��һЩʵ�õĹ��ܣ������ж�ָ������Դ�Ƿ���ڵķ�ʽ��  
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
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 