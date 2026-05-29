"""
文件上传服务模块
实现图片上传、压缩、格式转换等功能
"""
import io
import logging
import os
import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from app.config import settings

logger = logging.getLogger(__name__)

# 允许的图片类型
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp"}
ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp"
}

# 尝试导入 PIL，如果失败则使用降级模式
try:
    from PIL import Image, ExifTags
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    Image = None
    ExifTags = None
    _pil_warning_shown = False

def check_pil_availability():
    """检查 PIL 可用性并在需要时输出警告"""
    global _pil_warning_shown
    if not PIL_AVAILABLE and not _pil_warning_shown:
        logger.warning("PIL 不可用，图片将不进行压缩处理")
        _pil_warning_shown = True

# 类型检查时使用的类型（避免运行时导入问题）
if TYPE_CHECKING and PIL_AVAILABLE:
    from PIL import Image as PILImage


class UploadService:
    """文件上传服务"""

    async def upload_image(self, file, family_id: int) -> str:
        """
        上传并处理图片
        :param file: UploadFile 对象
        :param family_id: 家庭ID
        :return: 文件URL
        """
        # 验证文件类型
        await self._validate_file(file)

        # 读取文件内容
        file_content = await file.read()

        # 处理图片（如果 PIL 可用）
        if PIL_AVAILABLE:
            processed_image = self._process_image(file_content)
            filename = self._generate_filename(family_id)
        else:
            # 降级模式：直接保存原始文件
            processed_image = file_content
            # 使用原始文件名（安全处理）
            original_name = file.filename.lower()
            # 提取扩展名
            ext = original_name.split('.')[-1] if '.' in original_name else 'jpg'
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            unique_id = str(uuid.uuid4())[:8]
            filename = f"{timestamp}_{unique_id}.{ext}"

        # 创建家庭目录
        family_dir = os.path.join(settings.UPLOAD_DIR, str(family_id))
        os.makedirs(family_dir, exist_ok=True)

        # 保存文件
        file_path = os.path.join(family_dir, filename)
        with open(file_path, "wb") as f:
            f.write(processed_image)

        logger.info(f"图片上传成功: {filename}")

        # 返回URL
        return f"/uploads/{family_id}/{filename}"

    async def upload_images(self, files, family_id: int) -> List[str]:
        """
        批量上传图片（最多5张）
        :param files: UploadFile 列表
        :param family_id: 家庭ID
        :return: 文件URL列表
        """
        if len(files) > 5:
            raise ValueError("最多支持上传5张图片")

        urls = []
        for file in files:
            url = await self.upload_image(file, family_id)
            urls.append(url)

        return urls

    async def delete_image(self, url: str) -> bool:
        """
        删除图片文件
        :param url: 文件URL
        :return: 是否删除成功
        """
        # 提取文件路径
        if not url.startswith("/uploads/"):
            return False

        file_path = os.path.join(settings.UPLOAD_DIR, url[len("/uploads/"):])

        # 安全检查：确保路径在上传目录内
        if not file_path.startswith(os.path.abspath(settings.UPLOAD_DIR)):
            return False

        try:
            os.remove(file_path)
            logger.info(f"图片删除成功: {file_path}")
            return True
        except FileNotFoundError:
            logger.warning(f"图片不存在: {file_path}")
            return False
        except Exception as e:
            logger.error(f"删除图片失败: {e}")
            return False

    async def _validate_file(self, file) -> None:
        """
        验证文件
        :param file: UploadFile 对象
        """
        # 检查文件大小
        file.file.seek(0, os.SEEK_END)
        file_size = file.file.tell()
        file.file.seek(0)

        max_size = settings.MAX_FILE_SIZE_MB * 1024 * 1024
        if file_size > max_size:
            raise ValueError(f"文件大小超过限制（最大{settings.MAX_FILE_SIZE_MB}MB）")

        # 检查扩展名
        filename = (file.filename or "").lower()
        if not filename.endswith(tuple(f".{ext}" for ext in ALLOWED_EXTENSIONS)):
            raise ValueError("不支持的文件格式，仅支持 jpg/jpeg/png/webp")

        # 检查 MIME 类型（移动端常传 application/octet-stream，扩展名合法则放行）
        content_type = (file.content_type or "").lower().split(";")[0].strip()
        if content_type not in ALLOWED_MIME_TYPES:
            if content_type not in ("application/octet-stream", "binary/octet-stream", ""):
                raise ValueError("不支持的文件类型")

    def _process_image(self, file_content: bytes) -> bytes:
        """
        处理图片：旋转、缩放、转换格式
        :param file_content: 原始图片内容
        :return: 处理后的图片内容（WebP格式）
        """
        # 打开图片
        image = Image.open(io.BytesIO(file_content))

        # 处理 EXIF 旋转
        image = self._fix_exif_orientation(image)

        # 缩放图片
        image = self._resize_image(image)

        # 转换为 WebP 格式
        output_buffer = io.BytesIO()
        image.save(output_buffer, format="WEBP", quality=settings.IMAGE_QUALITY)

        return output_buffer.getvalue()

    def _fix_exif_orientation(self, image) -> any:
        """
        根据 EXIF 信息旋转图片
        :param image: PIL Image 对象
        :return: 旋转后的图片
        """
        try:
            exif = image._getexif()
            if exif is not None:
                for tag, value in exif.items():
                    if ExifTags.TAGS.get(tag) == 'Orientation':
                        if value == 3:
                            image = image.rotate(180, expand=True)
                        elif value == 6:
                            image = image.rotate(270, expand=True)
                        elif value == 8:
                            image = image.rotate(90, expand=True)
                        break
        except Exception as e:
            logger.warning(f"处理 EXIF 信息失败: {e}")

        return image

    def _resize_image(self, image) -> any:
        """
        等比缩放到最大宽度
        :param image: PIL Image 对象
        :return: 缩放后的图片
        """
        width, height = image.size

        if width <= settings.MAX_IMAGE_WIDTH:
            return image

        # 计算缩放比例
        ratio = settings.MAX_IMAGE_WIDTH / width
        new_height = int(height * ratio)

        # 缩放
        image = image.resize((settings.MAX_IMAGE_WIDTH, new_height), Image.Resampling.LANCZOS)

        return image

    def _generate_filename(self, family_id: int) -> str:
        """
        生成唯一文件名
        :param family_id: 家庭ID
        :return: 文件名
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        return f"{timestamp}_{unique_id}.webp"
