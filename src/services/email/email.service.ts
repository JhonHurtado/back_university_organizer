// =====================================================
// services/email/email.service.ts
// =====================================================
import nodemailer from "nodemailer";
import type { Transporter } from "nodemailer";

// =====================================================
// EMAIL SERVICE CONFIG
// =====================================================
const EMAIL_CONFIG = {
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: process.env.SMTP_SECURE === "true", // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
};

const FROM_EMAIL = process.env.FROM_EMAIL || process.env.SMTP_USER;
const FROM_NAME = process.env.FROM_NAME || "University Organizer";

// =====================================================
// EMAIL SERVICE
// =====================================================
class EmailService {
  private transporter: Transporter | null = null;

  // =====================================================
  // INITIALIZE TRANSPORTER
  // =====================================================
  private async getTransporter(): Promise<Transporter> {
    if (this.transporter) {
      return this.transporter;
    }

    // Si no hay configuración de SMTP, usar modo de prueba con Ethereal
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.warn("⚠️  No SMTP credentials found. Using Ethereal test account.");

      const testAccount = await nodemailer.createTestAccount();

      this.transporter = nodemailer.createTransport({
        host: "smtp.ethereal.email",
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass,
        },
      });

      console.log("📧 Email test account created:");
      console.log("   User:", testAccount.user);
      console.log("   Pass:", testAccount.pass);
      console.log("   Preview URL: https://ethereal.email");
    } else {
      this.transporter = nodemailer.createTransport(EMAIL_CONFIG);
    }

    // Verificar la conexión
    try {
      await this.transporter.verify();
      console.log("✅ Email service is ready");
    } catch (error) {
      console.error("❌ Email service failed to initialize:", error);
      throw new Error("EMAIL_SERVICE_INIT_FAILED");
    }

    return this.transporter;
  }

  // =====================================================
  // SEND EMAIL
  // =====================================================
  async sendEmail(options: {
    to: string;
    subject: string;
    html: string;
    text?: string;
  }): Promise<void> {
    const transporter = await this.getTransporter();

    const mailOptions = {
      from: `"${FROM_NAME}" <${FROM_EMAIL}>`,
      to: options.to,
      subject: options.subject,
      html: options.html,
      text: options.text || options.html.replace(/<[^>]*>/g, ""), // Strip HTML para texto plano
    };

    try {
      const info = await transporter.sendMail(mailOptions);

      // Si es Ethereal (cuenta de prueba), mostrar URL de preview
      if (info.messageId && process.env.NODE_ENV !== "production") {
        console.log("📧 Email sent:", info.messageId);
        const previewUrl = nodemailer.getTestMessageUrl(info);
        if (previewUrl) {
          console.log("   Preview URL:", previewUrl);
        }
      }
    } catch (error) {
      console.error("❌ Failed to send email:", error);
      throw new Error("EMAIL_SEND_FAILED");
    }
  }

  // =====================================================
  // SEND VERIFICATION EMAIL
  // =====================================================
  async sendVerificationEmail(
    email: string,
    firstName: string,
    token: string
  ): Promise<void> {
    const verificationUrl = `${process.env.FRONTEND_URL || "http://localhost:3000"}/verify-email?token=${token}`;

    const html = this.getVerificationEmailTemplate(firstName, verificationUrl);

    await this.sendEmail({
      to: email,
      subject: "Verifica tu dirección de correo electrónico",
      html,
    });
  }

  // =====================================================
  // SEND PASSWORD RESET EMAIL
  // =====================================================
  async sendPasswordResetEmail(
    email: string,
    firstName: string,
    token: string
  ): Promise<void> {
    const resetUrl = `${process.env.FRONTEND_URL || "http://localhost:3000"}/reset-password?token=${token}`;

    const html = this.getPasswordResetEmailTemplate(firstName, resetUrl);

    await this.sendEmail({
      to: email,
      subject: "Restablece tu contraseña",
      html,
    });
  }

  // =====================================================
  // SEND WELCOME EMAIL
  // =====================================================
  async sendWelcomeEmail(email: string, firstName: string): Promise<void> {
    const html = this.getWelcomeEmailTemplate(firstName);

    await this.sendEmail({
      to: email,
      subject: "¡Bienvenido a University Organizer!",
      html,
    });
  }

  // =====================================================
  // EMAIL TEMPLATES
  // =====================================================
  private getVerificationEmailTemplate(
    firstName: string,
    verificationUrl: string
  ): string {
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Verifica tu Email</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
          <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f4f4f4;">
            <tr>
              <td style="padding: 40px 0;">
                <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <!-- Header -->
                  <tr>
                    <td style="padding: 40px 40px 20px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px 8px 0 0;">
                      <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: bold;">University Organizer</h1>
                    </td>
                  </tr>

                  <!-- Content -->
                  <tr>
                    <td style="padding: 40px;">
                      <h2 style="margin: 0 0 20px; color: #333333; font-size: 24px;">¡Hola ${firstName}!</h2>
                      <p style="margin: 0 0 20px; color: #666666; font-size: 16px; line-height: 1.5;">
                        Gracias por registrarte en University Organizer. Para completar tu registro y verificar tu dirección de correo electrónico, haz clic en el botón de abajo:
                      </p>

                      <!-- Button -->
                      <table role="presentation" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                        <tr>
                          <td style="border-radius: 6px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                            <a href="${verificationUrl}" target="_blank" style="display: inline-block; padding: 14px 40px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; border-radius: 6px;">
                              Verificar Email
                            </a>
                          </td>
                        </tr>
                      </table>

                      <p style="margin: 20px 0 0; color: #666666; font-size: 14px; line-height: 1.5;">
                        Si no puedes hacer clic en el botón, copia y pega el siguiente enlace en tu navegador:
                      </p>
                      <p style="margin: 10px 0 0; color: #667eea; font-size: 14px; word-break: break-all;">
                        ${verificationUrl}
                      </p>

                      <p style="margin: 30px 0 0; color: #999999; font-size: 14px; line-height: 1.5;">
                        Este enlace expirará en 24 horas. Si no solicitaste este correo, puedes ignorarlo de forma segura.
                      </p>
                    </td>
                  </tr>

                  <!-- Footer -->
                  <tr>
                    <td style="padding: 30px 40px; background-color: #f8f8f8; border-radius: 0 0 8px 8px; text-align: center;">
                      <p style="margin: 0; color: #999999; font-size: 12px;">
                        © ${new Date().getFullYear()} University Organizer. Todos los derechos reservados.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
    `;
  }

  private getPasswordResetEmailTemplate(
    firstName: string,
    resetUrl: string
  ): string {
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Restablecer Contraseña</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
          <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f4f4f4;">
            <tr>
              <td style="padding: 40px 0;">
                <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <tr>
                    <td style="padding: 40px 40px 20px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px 8px 0 0;">
                      <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: bold;">University Organizer</h1>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding: 40px;">
                      <h2 style="margin: 0 0 20px; color: #333333; font-size: 24px;">Hola ${firstName},</h2>
                      <p style="margin: 0 0 20px; color: #666666; font-size: 16px; line-height: 1.5;">
                        Recibimos una solicitud para restablecer la contraseña de tu cuenta. Haz clic en el botón de abajo para crear una nueva contraseña:
                      </p>

                      <table role="presentation" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                        <tr>
                          <td style="border-radius: 6px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                            <a href="${resetUrl}" target="_blank" style="display: inline-block; padding: 14px 40px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: bold; border-radius: 6px;">
                              Restablecer Contraseña
                            </a>
                          </td>
                        </tr>
                      </table>

                      <p style="margin: 20px 0 0; color: #666666; font-size: 14px; line-height: 1.5;">
                        Si no puedes hacer clic en el botón, copia y pega el siguiente enlace en tu navegador:
                      </p>
                      <p style="margin: 10px 0 0; color: #667eea; font-size: 14px; word-break: break-all;">
                        ${resetUrl}
                      </p>

                      <p style="margin: 30px 0 0; color: #ff6b6b; font-size: 14px; line-height: 1.5; font-weight: bold;">
                        Este enlace expirará en 1 hora.
                      </p>
                      <p style="margin: 10px 0 0; color: #999999; font-size: 14px; line-height: 1.5;">
                        Si no solicitaste restablecer tu contraseña, puedes ignorar este correo de forma segura.
                      </p>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding: 30px 40px; background-color: #f8f8f8; border-radius: 0 0 8px 8px; text-align: center;">
                      <p style="margin: 0; color: #999999; font-size: 12px;">
                        © ${new Date().getFullYear()} University Organizer. Todos los derechos reservados.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
    `;
  }

  private getWelcomeEmailTemplate(firstName: string): string {
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>¡Bienvenido!</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
          <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f4f4f4;">
            <tr>
              <td style="padding: 40px 0;">
                <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <tr>
                    <td style="padding: 40px 40px 20px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px 8px 0 0;">
                      <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: bold;">¡Bienvenido a University Organizer!</h1>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding: 40px;">
                      <h2 style="margin: 0 0 20px; color: #333333; font-size: 24px;">¡Hola ${firstName}!</h2>
                      <p style="margin: 0 0 20px; color: #666666; font-size: 16px; line-height: 1.5;">
                        ¡Gracias por verificar tu cuenta! Estamos emocionados de tenerte con nosotros.
                      </p>
                      <p style="margin: 0 0 20px; color: #666666; font-size: 16px; line-height: 1.5;">
                        Con University Organizer puedes:
                      </p>
                      <ul style="margin: 0 0 20px; color: #666666; font-size: 16px; line-height: 1.8; padding-left: 20px;">
                        <li>Organizar tus carreras y materias</li>
                        <li>Llevar un registro de tus calificaciones</li>
                        <li>Gestionar tus horarios de clases</li>
                        <li>Recibir notificaciones importantes</li>
                        <li>Y mucho más...</li>
                      </ul>
                      <p style="margin: 20px 0 0; color: #666666; font-size: 16px; line-height: 1.5;">
                        ¡Comienza a explorar todas las funcionalidades que tenemos para ti!
                      </p>
                    </td>
                  </tr>

                  <tr>
                    <td style="padding: 30px 40px; background-color: #f8f8f8; border-radius: 0 0 8px 8px; text-align: center;">
                      <p style="margin: 0; color: #999999; font-size: 12px;">
                        © ${new Date().getFullYear()} University Organizer. Todos los derechos reservados.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
    `;
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const emailService = new EmailService();
